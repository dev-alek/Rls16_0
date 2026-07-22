block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение изменений в карточке МАСКИ ДИСКОНТНОЙ КАРТЫ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/17/04
Author: Bakhtadze Natalya
Creation date: 05/17/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec    as recid no-undo.
define input parameter parparentproc       as widget-handle                        no-undo .
define input parameter p-mode              as character no-undo .
define input parameter p-use-on            like ub.dis-card-mask.use-on            no-undo .
define input parameter p-cli-code          like ub.dis-card-mask.cli-code          no-undo .
define input parameter p-cli-mask          like ub.dis-card-mask.cli-mask          no-undo .
define input parameter p-cli-type          like ub.dis-card-mask.cli-type          no-undo .
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-host-code         like ub.dis-card-mask.host-code         no-undo .
define input parameter p-mask-num          like ub.dis-card-mask.mask-num          no-undo .
define input parameter p-mask              like ub.dis-card-mask.mask              no-undo .
define input parameter p-obj-code          like ub.dis-card-mask.obj-code          no-undo .
define input parameter p-obj-type          like ub.dis-card-mask.obj-type          no-undo .
define input parameter p-rank              like ub.dis-card-mask.rank              no-undo .
define input parameter p-type              like ub.dis-card-mask.type              no-undo .
define input parameter p-cc-run            like ub.dis-card-mask.cc-run            no-undo .
define input parameter p-reg-cash          as logical                              no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке МАСКИ ДИСКОНТНОЙ КАРТЫ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ trg/maskfunc.i }
{ ref/chdctmsk.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-ok as logical no-undo .
define variable v-descr as character no-undo .
define variable dc-ri as recid no-undo .
define variable v-check-by-mask  as character no-undo .
define variable v-type as character no-undo .
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .

define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients-obj for ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card-mask-attr  for ub.dis-card-mask-attr.

DEFINE TEMP-TABLE tt0-dis-card-property NO-UNDO LIKE ub.dis-card-property.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }

if v-db-num <> 0 then do:
  run err-mess in this-procedure ( substitute("Нельзя изменять запись МАСКИ ДИКОНТНОЙ КАРТЫ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.

/*проверим реляционность*/
find first buf_dis-card-type no-lock where
          buf_dis-card-type.emitent-host-code = p-emitent-host-code
     AND buf_dis-card-type.type = p-type  no-error .
if not available buf_dis-card-type then do:
  run err-mess  in this-procedure ( substitute("Неправильная ссылка на ТИП ДИСКОНТНОЙ КАРТЫ, код эмитента: &1, тип карты &2"
                , p-emitent-host-code, p-type) ).
  undo, return error "type":U.
end.

if p-host-code <> 0 then do:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code no-error .
  if not available buf_sysconf then do:
    run err-mess  in this-procedure ( substitute("Неправильная ссылка на ФИРМУ, код фирмы: &1"
                  , p-host-code) ).
    undo, return error "host-code":U.
  end.
end.

if p-obj-type <> "":U or p-obj-code <> 0 then do:
  find first buf_clients-obj no-lock where
            buf_clients-obj.obj-type = p-obj-type
        AND buf_clients-obj.obj-code = p-obj-code no-error .
  if not available buf_clients-obj then do:
    run err-mess  in this-procedure ( substitute("Неправильная ссылка на ОБЪЕКТ: &1&2"
                  , p-obj-type
                  , p-obj-code) ).
    undo, return error "obj-code":U.
  end.

end.

if p-cli-type <> "":U or p-cli-code <> 0 then do:
  find first buf_clients no-lock where
            buf_clients.obj-type = p-cli-type
        AND buf_clients.obj-code = p-cli-code no-error .
  if not available buf_clients then do:
    run err-mess  in this-procedure ( substitute("Неправильная ссылка на КОНТРАГЕНТА: &1&2"
                  , p-cli-type
                  , p-cli-code) ).
    undo, return error "cli-code":U.
  end.
end.
if lookup(string(p-use-on) , {&use-on-cd-codes}) = 0 then do:
    run err-mess  in this-procedure ( substitute("Неправильное значение поля ИСПОЛЬЗУЮТСЯ НА = &1"
                  , p-use-on) ).
    undo, return error "use-on":U.
end.

if lookup(string(p-cc-run) , {&dcm-cc-algo-codes}) = 0 then do:
    run err-mess  in this-procedure ( substitute("Неправильное значение поля АЛГОРИТМ КЦ = &1"
                  , p-cc-run) ).
    undo, return error "cc-run":U.
end.


if p-cli-mask <> "":U then do:
  if (length(p-cli-mask) <> length(entry(1, p-mask))
  and index(p-mask, "*") = 0)
  or length(p-cli-mask) < length(entry(1, p-mask))
  then do:
      run err-mess in this-procedure (substitute("НЕВЕРНАЯ длина маски КОРОТКОГО № &1"
                    ,p-cli-mask) ).
      undo, return error "mask":U.

  end.

  run check-cli-mask in this-procedure (
                                         input p-cli-mask
                                        ,input yes
                                        ,input "D,C":U /*p-addvalidchars*/
                                        ,input "D":U /*тип маски - вырезка код ДК*/
                                        ,input p-cc-run
                                        ,output v-ok
                                        ,output v-descr
                                        ) no-error .
  if error-status:error then do:
      run err-mess  in this-procedure ( substitute("Ошибка при проверке маски КОРОТКОГО № &1"
                    ,p-cli-mask) ).

      undo, return error "mask":U.
  end.
end.

if p-mode = {&add-def} then do:
  find first buf_dis-card-mask no-lock where
            buf_dis-card-mask.mask-num = p-mask-num no-error.
  if available buf_dis-card-mask then do:
      run err-mess  in this-procedure ( substitute("Неверно задан номер маски, в БД уже есть маска с номером &1"
                    , abs(p-mask-num)
                    ) ).
      undo, return error "mask-num":U.
  end.
end.


if p-mask = "":U then do:
    run err-mess in this-procedure ( substitute("Маска карты не может быть пустой"
                  ) ).
    undo, return error "mask":U.
end.
run check-mask-card in this-procedure (
                                        input p-mask
                                       ,input yes
                                       ,output v-ok
                                       ,output v-descr
                                      ) no-error .
if error-status:error then do:
    run err-mess  in this-procedure ( substitute("Ошибка при проверке маски &1"
                  ,p-mask) ).

    undo, return error "mask":U.
end.
if not v-ok then do:
    run err-mess  in this-procedure ( substitute("Неверная маска &1: &2"
                  ,p-mask
                  ,v-descr
                  ) ).
    undo, return error "mask":U.
end.

if p-mode = {&add-def} then do:
  if buf_dis-card-type.check-by-mask = 1 then do:
    run check-mask-correct-ho-join in this-procedure (
                                                 input p-emitent-host-code
                                                ,input p-type
                                                ,input p-mask
                                                ,input p-host-code
                                                ,input p-obj-type
                                                ,input p-obj-code
                                                ,output v-ok
                                                ) no-error .
    if error-status:error then do:
      run err-mess  in this-procedure ( substitute("Ввод маски &1 невозможен:&2&3 &4"
                             ,p-mask
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value
                             ) ).

      undo, return error "mask":U.
    end.
    else do:
      if not v-ok then do:
        run err-mess  in this-procedure (substitute("Ввод маски &1 невозможен:&2&3"
                             ,p-mask
                             , {&new-line}
                             , return-value
                             ) ).
        undo, return error "mask":U.
      end.
    end.
  end.
end.




_MAIN:
DO ON ERROR UNDO _main, RETURN ERROR
ON STOP UNDO _main, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.dis-card-mask.
    assign
    ub.dis-card-mask.mask-num             =  p-mask-num
    p-doc-rec = recid(ub.dis-card-mask)
    .
  end.
  else do:
    FIND FIRST ub.dis-card-mask where
              recid(ub.dis-card-mask) = p-doc-rec No-ERROR.
    if not available ub.dis-card-mask then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись МАСКА ДИСКОНТНОЙ КАРТЫ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo _main, return error '':u.
    end.
    if ub.dis-card-mask.mask-num <> p-mask-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "номер маски"
      view-as alert-box ERROR.
      undo _main, return error '':U.
    end.
  end.
  if can-find(first buf_dis-card-mask no-lock where
                    buf_dis-card-mask.rank = p-rank
              AND (p-mode = {&add-def}
                    or recid(buf_dis-card-mask) <> recid(ub.dis-card-mask)
                  )
              AND buf_dis-card-mask.stts = integer({&current-status-int})
             ) then do:
      run err-mess  in this-procedure ( substitute("Уже есть маска с рангом(приоритетом) поиска &1"
                    , p-rank
                    ) ).
      undo _main, return error "mask":U.

  end.
  if p-cli-code <> 0 then do:
    find first buf_dis-card no-lock where
              buf_dis-card.d-card = p-mask  no-error .
    if not available buf_dis-card then do:
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-pcnt}
        v-d-pcnt
      }
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-pcnt}
        v-cash-d-pcnt
      }
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-categ}
        v-categ
      }
      
      if v-d-pcnt = ? then do:
        v-d-pcnt = 0.
      end.
      if v-cash-d-pcnt = ? then do:
        v-cash-d-pcnt = 0.
      end.
      if v-categ = ? then do:
        v-categ = 0.
      end.

      run ref/dcardi01.p (
                     input parparentproc
                    ,input this-procedure
                    ,input ?
                    ,input ? /*handle для вызова процедур истории и маршрутизации - используется в saledc*/
                    ,input yes    /*p-silent*/
                    ,input-output dc-ri
                    ,input {&add-def}
                    ,input '':U /*par-mode2*/
                    ,input "":U /*p-curr-obj-type*/
                    ,input 0    /*p-curr-obj-code*/
                    ,input p-mask
                    ,input p-emitent-host-code
                    ,input p-cli-type
                    ,input p-cli-code
                    ,input {&current-status}
                    ,input p-type
                    ,input v-d-pcnt
                    ,input v-cash-d-pcnt
                    ,input v-categ
                    ,input buf_dis-card-type.dflt-d-pcnt-method
                    ,input buf_dis-card-type.dflt-credit-card
                    ,input buf_dis-card-type.lim-kr
                    ,input buf_dis-card-type.dflt-debet-card
                    ,input buf_dis-card-type.dflt-staff-card
                    ,input today /*buf_dis-card-type.issue-date*/
                    ,input (if p-obj-code <> 0 then p-obj-code else 0) /*p-issue-code*/
                    ,input today /*valid-from*/
                    ,input ? /*valid-date*/
                    ,input "":U /*sourced-card*/
                    ,input "":U /*cli-message*/
                    ,input yes /*mask-card*/
                    ,input p-mask /*main-card*/
                    ,input no /*is-subsid*/
                    ,INPUT no /*p-update-prop*/
                    ,INPUT table tt0-dis-card-property

                      ) no-error.
      if error-status:error then do:
        message
        "Ошибка при сохранении записи КАРТЫ-МАСКИ" skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo _main, return error 'mask':U.
      end.
    end. /*add-def dis-card*/
    else do:
      if not (buf_dis-card.cli-type  = p-cli-type
            AND
            buf_dis-card.cli-code  = p-cli-code)
      or buf_dis-card.type <> p-type
      or buf_dis-card.emitent-host-code <> p-emitent-host-code then do:
      assign
      dc-ri = recid(buf_dis-card)
      .
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-pcnt}
        v-d-pcnt
      }
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-pcnt}
        v-cash-d-pcnt
      }
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        0
        '':U
        0
        {&ddctr-def-categ}
        v-categ
      }
      if v-d-pcnt = ? then do:
        v-d-pcnt = 0.
      end.
      if v-cash-d-pcnt = ? then do:
        v-cash-d-pcnt = 0.
      end.

      if buf_dis-card.category = ? then do:
        v-categ = 0.
      end. 
      else do:
      v-categ = buf_dis-card.category.
      end. 
      /* message  v-categ  view-as alert-box. */
      run ref/dcardi01.p (
                     input parparentproc
                    ,input this-procedure
                    ,input ?
                    ,input ? /*handle для вызова процедур истории и маршрутизации - используется в saledc*/
                    ,input no    /*p-silent*/
                    ,input-output dc-ri
                    ,input {&update}
                    ,input '':U /*par-mode2*/
                    ,input "":U /*p-curr-obj-type*/
                    ,input 0    /*p-curr-obj-code*/
                    ,input p-mask
                    ,input p-emitent-host-code
                    ,input p-cli-type
                    ,input p-cli-code
                    ,input {&current-status}
                    ,input p-type
                    ,input v-d-pcnt
                    ,input v-cash-d-pcnt
                    ,input v-categ
                    ,input buf_dis-card-type.dflt-d-pcnt-method
                    ,input buf_dis-card-type.dflt-credit-card
                    ,input buf_dis-card-type.lim-kr
                    ,input buf_dis-card-type.dflt-debet-card
                    ,input buf_dis-card-type.dflt-staff-card
                    ,input today /*buf_dis-card-type.issue-date*/
                    ,input (if p-obj-code <> 0 then p-obj-code else 0) /*p-issue-code*/
                    ,input buf_dis-card.valid-from /*valid-from*/
                    ,input buf_dis-card.valid-date /*valid-date*/
                    ,input "":U /*sourced-card*/
                    ,input "":U /*cli-message*/
                    ,input yes /*mask-card*/
                    ,input buf_dis-card.main-card /*main-card*/
                    ,input no /*is-subdi*/
                    ,INPUT no /*p-update-property*/
                    ,INPUT table tt0-dis-card-property
                      ) no-error.
        if error-status:error then do:
          undo _main, return error 'mask':U.
        end.
      end. /*update dis-card*/
    end.
  end.
  assign
  ub.dis-card-mask.cli-code             =  p-cli-code
  ub.dis-card-mask.cli-mask             =  p-cli-mask
  ub.dis-card-mask.cc-run               =  p-cc-run
  ub.dis-card-mask.cli-type             =  p-cli-type
  ub.dis-card-mask.emitent-host-code    =  p-emitent-host-code
  ub.dis-card-mask.host-code            =  p-host-code
  ub.dis-card-mask.mask                 =  p-mask
  ub.dis-card-mask.use-on               =  p-use-on
  ub.dis-card-mask.obj-code             =  p-obj-code
  ub.dis-card-mask.obj-type             =  p-obj-type
  ub.dis-card-mask.rank                 =  p-rank
  ub.dis-card-mask.type                 =  p-type
  ub.dis-card-mask.stts                 =  (if p-mode = {&add-def}
                             then integer({&current-status-int})
                             else ub.dis-card-mask.stts)
  .
  release ub.dis-card-mask no-error.
  if error-status:error then do:
     run err-mess  in this-procedure ( substitute("Ошибка при сохранении записи МАСКИ ДИСКОНТНОЙ КАРТЫ с номером маски &1: &2 -  &3"
                             , p-mask-num
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo _main, return error "":U.
 end.
  find first buf_dis-card-mask-attr exclusive-lock where buf_dis-card-mask-attr.attr-code = "reg-cash" and buf_dis-card-mask-attr.mask-num = p-mask-num no-error .
  if available (buf_dis-card-mask-attr) then do:
    if p-reg-cash = yes then buf_dis-card-mask-attr.attr-value = "yes" .
    else buf_dis-card-mask-attr.attr-value = "no" .
  end.  
  else do:
    if p-reg-cash then do:
      create buf_dis-card-mask-attr .
      assign
      buf_dis-card-mask-attr.mask-num   = p-mask-num
      buf_dis-card-mask-attr.attr-code  = "reg-cash"
      buf_dis-card-mask-attr.attr-value = "yes"
      .
    end.  
  end.  

end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.