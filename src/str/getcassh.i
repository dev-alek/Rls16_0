/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

–абота со сменами при приеме чеков

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 01/17/06
Author: Bakhtadze Natalya
Creation date: 01/17/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if cas-shft then do:
  /*на кассах есть смены*/
  if current-pay-desk <> pay-desk_  or
  NOT (current-cas-shift-name =  shift-name_ AND current-cas-shift-date = shift-date_) OR
  not avail shift-cash OR "{1}" <> "" /*чек закрыти€ смены */ then do:
    if l-shift-on then do:
   /*если пришел чек от новой кассы  или чек с новой сменой
   ищем запись о кассовой смене дл€ данного чека*/
      _sc:
      for each  buf_shift-cash Exclusive-LOCK WHERE
                (buf_shift-cash.obj-type = shop-type
            AND buf_shift-cash.obj-code = shop-code
            AND buf_shift-cash.cash-num = pay-desk_
            AND buf_shift-cash.shift-date = shift-date_
            AND buf_shift-cash.src-shift-name = shift-name_)
        or
                (buf_shift-cash.obj-type = shop-type
            AND buf_shift-cash.obj-code = shop-code
            AND buf_shift-cash.cash-num = pay-desk_
            AND buf_shift-cash.shift-date = shift-date_
            AND buf_shift-cash.shift-name = shift-name_) :

        if BUF_shift-cash.src-shift-name = shift-name_
        or BUF_shift-cash.shift-name = shift-name_
        then do:
          /*это первый чек по смене -мы уже читали*/
          IF buf_shift-cash.shift-date = chk-date_
          and BUF_shift-cash.shift-open-time = chk-time_
          and BUF_shift-cash.src-shift-name = shift-name_
          and "{1}" = ""
          and buf_shift-cash.opened = {&receipt-in}
          then  do:
            LEAVE _sc.
          end.
          /*эту смену мы уже закрыли*/
          IF BUF_shift-cash.shift-close-date = chk-date_
          and BUF_shift-cash.shift-close-time = chk-time_
          and (BUF_shift-cash.src-shift-name = shift-name_
              or
              (BUF_shift-cash.shift-name = shift-name_
              and
              buf_shift-cash.opened <> {&receipt-in})
              or
              (BUF_shift-cash.shift-name = shift-name_
              and
              BUF_shift-cash.src-shift-name <> shift-name_)
            )
          and ("{1}" <> ""
              and
              buf_shift-cash.status_ = {&sht-closed})
          then  do:
            LEAVE _sc.
          end.
          if buf_shift-cash.opened <> {&receipt-in}
          and buf_shift-cash.shift-num <> ? then do:
            find first shift-obj no-lock where
                      Shift-obj.obj-type = shop-type
                  AND shift-obj.obj-code = shop-code
                  AND shift-obj.shift-date = buf_shift-cash.shift-date
                  and shift-obj.shift-num = buf_shift-cash.shift-num No-ERROR.
            if available shift-obj and
            shift-obj.status_ = {&fact} then next _sc.
          end.
          /*кажетс€ набрели на нужную*/
          leave _sc.
        end.
      end.
    end. /*l-shift-on*/
    assign current-pay-desk = pay-desk_.
    /*если в Ѕќ есть запись о кассовой смене запоминаем в переменные чтобы сравнива
    с этими переменными последующие приход€щие чеки мы отследили когда придет чек со
    сменой, о которой мы не знаем*/
    IF AVAIL buf_shift-cash
    and buf_shift-cash.shift-num <> 0
    and buf_shift-cash.shift-num <> ?
    then
    assign
    current-cas-shift-num  = buf_shift-cash.shift-num
    current-cas-shift-name = shift-name_
    current-cas-shift-date = buf_shift-cash.shift-date
    current-cas-shift-status_ = buf_shift-cash.status_
    .
    else do:
      /*если нет записи о кассовой смене - то создаем ее с текущим статусом*/
      run str/shftccr.p (  input shop-type
                      ,input shop-code
                      ,input pay-desk_
                      ,input shift-date_
                      ,input (if l-shift-on then ? else shift-name_)
                      ,input shift-name_
                      ,input (if l-shift-on then ? else integer(shift-name_))
                      ,input (if "{1}" <> ""
                              then shift-open-time_
                              else (if chk-date_ = shift-date_ then chk-time_ else ?)
                              )
                      ,input z-num_
                      ,input {&receipt-in}
                      ,output vrecid) no-error.
      if error-status:error then do:
        assign
        p-view-log = yes
        .
        run write-log-and-file in {2} (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!ѕроизошла ошибка при попытке создани€ записи кассовой смены дл€ кассы &1: смена N&2 за &3"
                                , pay-desk_
                                , shift-name_
                                , string(shift-date_, "99/99/9999")
                              )
                                              ).
      end.
      else do:
        FIND FIRST buf_shift-cash WHERE recid(buf_shift-cash) = vrecid.
        assign
        current-cas-shift-name = shift-name_
        current-cas-shift-num = buf_shift-cash.shift-num
        current-cas-shift-date = shift-date_
        current-cas-shift-status_ = {&sht-current}
        .
      end.
    end.
    if avail buf_shift-cash then do:
      /*включены глобальные смены на объекте*/
      if l-shift-on then do:
        if current-cas-shift-num  = ? then do:
          run get-shift-num  in this-procedure (
                                                input  shop-type
                                                ,input  shop-code
                                                ,input  current-cas-shift-date
                                                ,input  current-cas-shift-name
                                                ,output current-cas-shift-num ) no-error .
        end.
        if current-cas-shift-num <> ? then do:
          FIND FIRST shift-obj NO-LOCK WHERE
                      Shift-obj.obj-type = shop-type AND
                      shift-obj.obj-code = shop-code AND
                      shift-obj.shift-date = current-cas-shift-date AND
                      shift-obj.shift-num = current-cas-shift-num No-ERROR.
        end.
        else release shift-obj.
        if avail shift-obj then
        current-shift-status_ = shift-obj.status_.
        /*если нет записи о смене объекта считаем что Ѕќ просто опаздывает 0 торговл€ на кассах началась*/
        else
        current-shift-status_ = {&sht-current}.
      end.
      if "{1}" <> ""  then do:
        /*пришел чек закрыти€ смены - закроем кассовую смену в Ѕќ*/
        assign
        buf_shift-cash.status_ = {&sht-closed}
        buf_shift-cash.z-num = z-num_
        buf_shift-cash.closed = {&receipt-in}
        buf_shift-cash.shift-num = (if buf_shift-cash.shift-num = ?
                                and not can-find(first shift-cash where
                                                      shift-cash.obj-type = buf_shift-cash.obj-type
                                                 and  shift-cash.obj-code = buf_shift-cash.obj-code
                                                 and  shift-cash.cash-num = current-cas-shift-num
                                                 and  shift-cash.shift-date = buf_shift-cash.shift-date
                                                 and  shift-cash.shift-num = buf_shift-cash.shift-num
                                                 and  shift-cash.src-shift-name = buf_shift-cash.src-shift-name
                                                 and  recid(shift-cash) <> recid(buf_shift-cash)
                                                 )
                                then current-cas-shift-num
                                else buf_shift-cash.shift-num)
        buf_shift-cash.shift-name = if buf_shift-cash.shift-num <> ?
                                    then current-cas-shift-name
                                    else buf_shift-cash.shift-name
        buf_shift-cash.shift-open-time  = (if buf_shift-cash.shift-open-time > shift-open-time_
                                           then shift-open-time_
                                           else buf_shift-cash.shift-open-time)
        buf_shift-cash.shift-close-date = (if buf_shift-cash.shift-close-date = ?
                                           or buf_shift-cash.shift-close-date < chk-date_
                                            then chk-date_
                                            else buf_shift-cash.shift-close-date)
        buf_shift-cash.shift-close-time = (if buf_shift-cash.shift-close-time = 0
                                            or (buf_shift-cash.shift-close-date = chk-date_
                                                and
                                                buf_shift-cash.shift-close-time < chk-time_)
                                            then chk-time_
                                            else buf_shift-cash.shift-close-time)
        .
      end.
    end. /*if avail shift-cash*/
  end.  /**/
end. /*if cas-shft*/

/* $Workfile$ e n d */