block-level on error undo, throw.
/*

$Revision: 8e9f7b2574c4, 2516, test $
$Author: DRuban $
$Date: Вт авг 04 12:57:16 2020 +0300 $
$Workfile: cashdsk3.p $
$Archive: ref/cashdsk3.p $

Процедура удаления кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/19/05
Author: Bakhtadze Natalya
Creation date: 09/19/05

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-doc-rec as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision: 8e9f7b2574c4, 2516, test $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 04 12:57:16 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cashdsk3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cashdsk3.p $":U .
define variable vss-description as character no-undo init "Процедура удаления кассы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ ref/cp-attr.i }
{ str/wth-lib.i }

define variable var-stock like ub.wth-pobj.income-pl no-undo .
define variable v-rid as recid no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-entry as integer no-undo .
define variable v-host-code like ub.sysconf.host-code  no-undo .
DEFINE VARIABLE parstock like ub.wth-pobj.income-pl no-undo .
define variable l-shift-on as logical no-undo.
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable v-shift-name as character no-undo.
define variable v-log-del as logical no-undo .
define variable v-cd-list as character no-undo .
define variable cas-shft as logical no-undo .
define variable glog as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

define buffer buf_cash-desk  for ub.cash-desk.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_inkas for ub.inkas.
define buffer man_cash-desk for ub.cash-desk .
define buffer mar_cash-desk for ub.cash-desk.


_main:
do
on error undo _main, return error return-value
:
  find first buf_cash-desk exclusive-lock where
              recid(buf_cash-desk) = p-doc-rec No-ERROR.
  if not avail buf_cash-desk then return error substitute("Не найдена касса с recid &1", p-doc-rec).
  /*проверим наличие чеков отвязанных и в незакрытой продаже*/
  for each buf_chk-doc no-lock where
          buf_chk-doc.obj-type = {&shop}
      AND buf_chk-doc.obj-code = buf_cash-desk.obj-code
      and buf_chk-doc.out-code = ?
      and buf_chk-doc.pay-desk = buf_cash-desk.cash-num:
    undo _main, return error substitute("На объекте &1 имеются чеки по кассе, не привязанные к продаже&2Удалить кассу &3 маг &1 &4 невозможно"
                    ,buf_cash-desk.obj-code
                    , {&new-line}
                    , buf_cash-desk.cash-num
                    , buf_cash-desk.pos-type).
  end.
  for each buf_inkas no-lock where
          buf_inkas.obj-type = {&shop}
      and buf_inkas.obj-code = buf_cash-desk.obj-code,
     first buf_chk-doc no-lock where
          buf_chk-doc.obj-type = {&shop}
      AND buf_chk-doc.obj-code = buf_cash-desk.obj-code
      and buf_chk-doc.out-code = buf_inkas.inkas-code
      and buf_chk-doc.pay-desk = buf_cash-desk.cash-num
   break
   by buf_inkas.obj-type
   by buf_inkas.obj-code
   by buf_inkas.status_:
    if first-of(buf_inkas.status_) then do:
      if buf_inkas.status_ <> {&fact}
      and buf_inkas.status_ <> {&inquiry} then do:
        undo _main, return error substitute("На объекте &1 имеются чеки по кассе, привязанные к незакрытой продаже&2Удалить кассу &3 маг &1 &4 невозможно"
                        ,buf_cash-desk.obj-code
                        , {&new-line}
                        , buf_cash-desk.cash-num
                        , buf_cash-desk.pos-type).
      end.
    end.
  end.
  /*найдем параметр - использовать смены глобально на объекте или нет*/
  { gbl/objat.i
    {&shop}
    buf_cash-desk.obj-code
    "'shift-on=request'"
    l-shift-on
  }
 /*найдем использвуются ли смены на кассе*/
 { gbl/cas-shft.i {&shop}  buf_cash-desk.obj-code  cas-shft }
  if cas-shft then do:
    find last buf_shift-cash No-LOCK WHERE
                      buf_shift-cash.obj-type = {&shop} AND
                      buf_shift-cash.obj-code = buf_cash-desk.obj-code AND
                      buf_shift-cash.cash-num = buf_cash-desk.cash-num  no-error .
    if available buf_shift-cash
    and  buf_shift-cash.status_ <> {&sht-closed}  then do:
      undo _main, return error substitute("Последняя смена по кассе НЕ ЗАКРЫТА&2Удалить кассу &3 маг &1 &4 невозможно"
                      ,buf_cash-desk.obj-code
                      , {&new-line}
                      , buf_cash-desk.cash-num
                      , buf_cash-desk.pos-type).
    end.
  end.
  if l-shift-on then do:
    { gbl/curshift.i {&shop}   buf_cash-desk.obj-code v-shift-date v-shift-num v-shift-name no-error }
    if not error-status:error and v-shift-num > 0 then do:
       undo _main, return error substitute("На объекте &1 открыта смена&2Удалить кассу &3 маг &1 &4 невозможно"
                        ,buf_cash-desk.obj-code
                        , {&new-line}
                        , buf_cash-desk.cash-num
                        , buf_cash-desk.pos-type).
    end.
  end.

  /*проверим на наличие матценностей*/
  if buf_cash-desk.is-del = no then do:
    find first ub.wth-place No-LOCK WHERE
                ub.wth-place.obj-type = {&shop} AND
                ub.wth-place.obj-code = buf_cash-desk.obj-code AND
                ub.wth-place.cash-desk = buf_cash-desk.cash-num No-ERROR.
    if avail ub.wth-place then do:
      find first ub.wth-line No-LOCK WHERE
                ub.wth-line.obj-type = {&shop} and
                ub.wth-line.obj-code = buf_cash-desk.obj-code and
                ub.wth-line.w-p-code = wth-place.w-p-code No-ERROR.
      if avail ub.wth-line then do:
        message
        substitute("Нельзя удалить кассу &1 маг &2 &3- по МХ МЦ, привязанному к данной кассе&4" +
                                  "есть движение МЦ&4"  +
                                  "Касса будет помечена, как удаленная логически"
                                  , buf_cash-desk.cash-num
                                  , buf_cash-desk.obj-code
                                  , buf_Cash-desk.pos-type
                                  , {&new-line} )
        view-as alert-box QUESTION buttons YES-NO update v-log-del.
        if not v-log-del then undo _main, return.
      end.
    end.
  end.
/*  cas-shft = no.*/
  if buf_cash-desk.is-del = yes then do:
/*------*/
    if  cas-shft
    then 
       find first buf_shift-cash No-LOCK WHERE
            buf_shift-cash.cash-num = buf_cash-desk.cash-num AND
            buf_shift-cash.obj-code = buf_cash-desk.obj-code AND
            buf_shift-cash.obj-type = {&shop} no-error .
    if cas-shft and available buf_shift-cash
    then do:
       message
          substitute("Касса &1 помечена как удаленная и на ней есть смены. Хотите востановить кассу ?"
                , buf_cash-desk.cash-num
                , {&new-line}
                )
       view-as alert-box QUESTION buttons YES-NO update glog.
       if not glog then undo _main, return .
        
    end.
    else if available buf_shift-cash then do:
       message
          substitute("Вы действительно хотите ОКОНЧАТЕЛЬНО удалить кассу &1?&2(Данная касса уже ЛОГИЧЕСКИ удалена)"
                , buf_cash-desk.cash-num
                , {&new-line}
                )
          view-as alert-box QUESTION buttons YES-NO update glog.
       if not glog then undo _main, return .
    end.
  end.

  for each ub.wth-pobj No-LOCK WHERE
            ub.wth-pobj.obj-type = {&shop} AND
            ub.wth-pobj.obj-code = buf_cash-desk.obj-code AND
            ub.wth-pobj.w-p-code = wth-place.w-p-code
            :
    run wth-lib_cur-stock-place in this-procedure (
                                                      input {&shop}
                                                    ,input buf_cash-desk.obj-code
                                                    ,input wth-place.w-p-code
                                                    ,input ub.wth-pobj.wth-code
                                                    ,output var-stock) no-error .
    if var-stock <> 0 then do:
      message
      substitute("&1&2" +
                  "Нельзя удалить кассу &3 маг &4 &5&2" +
                  "было движение по соответствующему МХ МЦ или остаток МЦ с кодом &6 на нем <> 0&2" +
                  "Касса будет помечена, как удаленная логически"
                  , substitute("&1 &2 &3", vss-workfile, vss-revision ,vss-description )
                  ,{&New-line}
                  , buf_cash-desk.cash-num
                  , buf_Cash-desk.obj-code
                  , buf_Cash-desk.pos-type
                  , wth-pobj.wth-code)
      view-as alert-box QUESTION buttons YES-NO update v-log-del .
      if not v-log-del then undo _main, return.
    end.
  END.
  if buf_cash-desk.is-del = yes
  then 
     v-log-del = yes.
  else if cas-shft then do:
    find first buf_shift-cash No-LOCK WHERE
            buf_shift-cash.cash-num = buf_cash-desk.cash-num AND
            buf_shift-cash.obj-code = buf_cash-desk.obj-code AND
            buf_shift-cash.obj-type = {&shop} no-error .
    if available buf_shift-cash then do:
      assign
      v-log-del = yes.
      message
      substitute("Нельзя удалить кассу &1 маг &2 &3- имеются смены на данной кассе&4" +
                  "Касса будет помечена, как удаленная логически"
                  , buf_cash-desk.cash-num
                  , buf_cash-desk.obj-code
                  , buf_Cash-desk.pos-type
                  , {&new-line} )
      view-as alert-box QUESTION buttons YES-NO update v-log-del .
      if not v-log-del then undo _main, return.
    end.
  end.
  if buf_cash-desk.pos-type = {&cd-type-maria}
  and buf_cash-desk.autonomy = integer({&cd-manager})
  and  can-find(first ub.cash-desk where
                      ub.cash-desk.obj-code = buf_cash-desk.obj-code
                  and ub.cash-desk.pos-type  = buf_cash-desk.pos-type
                  and ub.cash-desk.autonomy  = integer({&cd-slave})
                  and ub.cash-desk.is-del  = no
                  ) then do:
    message
    substitute("Нельзя изменить/удалить кассовый менеджер &1&2" +
                "На объекте еще имеются подчиненные кассы этого типа"
                , {&cd-type-maria}
                , {&new-line})
    view-as alert-box error .
    undo, return error ''.
  end.
  if v-log-del = yes
  then do:
      v-rid = recid(buf_cash-desk).
      run ref/cashdsk1.p (
                    input-output v-rid
                    ,input {&update}
                    ,input buf_cash-desk.db-num
                    ,input buf_cash-desk.obj-code
                    ,input buf_cash-desk.pos-type
                    ,input buf_cash-desk.cash-num
                    ,input buf_cash-desk.autonomy
                    ,input buf_cash-desk.addr-path
                    ,input no /*buf_cash-desk.cash-on*/
                    ,input buf_cash-desk.cash-os
                    ,input yes
                    ,input buf_cash-desk.remote
                    ,input buf_cash-desk.version
                    ,input buf_cash-desk.registration-code
                    ,input buf_cash-desk.serial-code
                    ,input buf_cash-desk.fr-type
                    ,input ? /* вариант исполнения кассы (ТСО,неТСО,мобильн); "?" = "оставить прежнее значение" */
                    ) no-error .
                    if error-status:error then do:
                      undo _main, return error substitute("&1&2&3", error-status:get-message(1) , {&new-line}, return-value ).
                    end.
  end.
  else do:
    /*надо проверить атрибут is-use для cash-pay*/
    { gbl/hostcode.i {&shop} buf_cash-desk.obj-code v-host-code }
    for each buf_cash-pay-attr no-lock where
            buf_cash-pay-attr.host-code = v-host-code
        AND buf_cash-pay-attr.obj-type = {&shop}
        AND buf_cash-pay-attr.obj-code = buf_cash-desk.obj-code
        AND buf_cash-pay-attr.attr-code = {&cp-attr-is-use}:
      run cp-attr-value  in this-procedure (
                                            input buf_cash-pay-attr.cdpay-code
                                          , input buf_cash-pay-attr.curr-code
                                          , input buf_cash-pay-attr.host-code
                                          , input buf_cash-pay-attr.obj-type
                                          , input buf_cash-pay-attr.obj-code
                                          , input buf_cash-pay-attr.attr-code
                                          , output v-value
                                          , output v-type) no-error .
      if not error-status:error
      and v-value <> '':U then do:
        assign v-entry = lookup(string(buf_cash-desk.cash-num) + {&comma-char} + buf_cash-desk.pos-type, v-value, {&delim-par} ).
        if v-entry > 0 then do:
          assign
          entry(v-entry, v-value, {&delim-par}) =  '':U
          v-value = replace(v-value, ( {&delim-par} + {&delim-par} ), {&delim-par} )
          .
          run  cp-attr-write  in this-procedure (
                                            input buf_cash-pay-attr.cdpay-code
                                          , input buf_cash-pay-attr.curr-code
                                          , input buf_cash-pay-attr.host-code
                                          , input buf_cash-pay-attr.obj-type
                                          , input buf_cash-pay-attr.obj-code
                                          , input buf_cash-pay-attr.attr-code
                                          , input v-value) no-error .
          if error-status:error then do:
            undo _main, return error
              substitute('Ошибка при попытке обновить атрибут типа кассового платежа, использующий ссылку&1' +
                        'на кассу &2 маг &3 &4&1' +
                        '&5&1&6'
                      , {&new-line}
                      , buf_cash-desk.cash-num
                      , buf_cash-desk.obj-code
                      , buf_cash-desk.pos-type
                      , error-status:get-message(1)
                      , return-value ).
          end.
        end. /*if v-entry > 0 then do:*/
      end. /*    if not error-status:error
          and v-value <> '':U then do: */
    end. /*  for each buf_cash-pay-attr no-lock where*/
    if buf_cash-desk.pos-type = {&cd-type-maria}
    and buf_cash-desk.autonomy = integer({&cd-slave})
    then do:
      find first man_cash-desk exclusive-lock where
                man_cash-desk.obj-code = buf_cash-desk.obj-code
            and man_cash-desk.pos-type = buf_cash-desk.pos-type
            and man_cash-desk.autonomy = integer({&cd-manager}) .
      for each mar_cash-desk where
              mar_cash-desk.obj-code = buf_cash-desk.obj-code
            and mar_cash-desk.pos-type = buf_cash-desk.pos-type
            and mar_cash-desk.autonomy = integer({&cd-slave})
            and mar_cash-desk.is-del   = no:
        if mar_cash-desk.cash-num = buf_cash-desk.cash-num then next.
        assign
        v-cd-list = v-cd-list + (if v-cd-list = '':U then '':U else {&comma-char}) + string(mar_cash-desk.cash-num).
      end.
      man_cash-desk.addr-path = v-cd-list.
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    if not cas-shft then do:
      for each buf_shift-cash where
            buf_shift-cash.cash-num = buf_cash-desk.cash-num
          AND buf_shift-cash.obj-code = buf_cash-desk.obj-code
          AND buf_shift-cash.obj-type = {&shop}
      on error undo _main, return error
      on stop undo _main, return error :
        delete buf_shift-cash.
      end.
    end.
    run waitfram-hide in this-procedure .
    delete buf_cash-desk no-error .
    if error-status:error then undo _main,
    return error substitute("&1&2&3", error-status:get-message(1) , {&new-line}, return-value ).
  end. /*с МЦ все в порядке*/
end. /*doe*/