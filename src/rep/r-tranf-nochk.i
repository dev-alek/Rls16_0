/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Инклюд обработки топливной транзации без чека и добавление записи транзакции  в temp-table tt-rep

Автор: Ростовцев Александр
Дата создания: 24/05/23
Author: Rostovtsev Alexandr
Creation date: 24/05/23
Used by: r-tranfuel.p (r-tranfuel.i)

*/
for first obj-list where
          obj-list.obj-type = {&shop}
      and obj-list.obj-code = tran-fuel.obj-code
no-lock:
   /* Если это транзакция заказа техпролива, то исключаем */
  for first b-tran-fuel where
            b-tran-fuel.db-num    =  tran-fuel.db-num
        and b-tran-fuel.uuid      =  tran-fuel.uuid
        and b-tran-fuel.uuid-cheq <> tran-fuel.uuid-cheq
  no-lock,
      first chk-doc-attr where
            chk-doc-attr.attr-code  = "CheckId"
        and chk-doc-attr.attr-value = b-tran-fuel.uuid-cheq
  no-lock,
      first chk-doc where
            chk-doc.doc-code = chk-doc-attr.doc-code
        and chk-doc.chk-type = 17
  no-lock:
     next TRAN-FUEL.
  end.
   
  v-gds-code = tran-fuel.fuel-code.
  if v-gds-code < 100 then do: /* Если короткий код, то ищем полный код */
    find first prod-bc where
               prod-bc.b-str = string(v-gds-code)
    no-lock no-error.
    if avail prod-bc then do:
       find first goods where
                  goods.gds-code = prod-bc.b-code
       no-lock no-error.
       if not avail goods then
          next TRAN-FUEL.
       v-gds-code = goods.gds-code.
    end.
  end.
  else do:
     find first goods where
                goods.gds-code = v-gds-code
     no-lock no-error.
     if not avail goods
     then
        next TRAN-FUEL.
  end.
  if not can-do(iGdsCodeList, string(v-gds-code)) then next TRAN-FUEL.

  /* Корректировка по часовому поясу */
  assign
    vDateBeg = tran-fuel.date-beg + timezone * 60000
    vDateEnd = tran-fuel.date-end + timezone * 60000
  .
  create tt-rep.
  assign
    tt-rep.obj-type        = obj-list.obj-type
    tt-rep.obj-code        = obj-list.obj-code
    tt-rep.obj-name        = obj-list.obj-name
    tt-rep.sort-date       = date(vDateBeg)
    tt-rep.sort-time       = mtime(vDateBeg) / 1000
    tt-rep.chk-num         = tran-fuel.num-cheq
    tt-rep.tran-num        = tran-fuel.tran-num
    tt-rep.cash-num        = tran-fuel.cash-num
    tt-rep.trk-num         = tran-fuel.trk-num + 1
    tt-rep.nozzle-num      = tran-fuel.nozzle-num + 1
    tt-rep.fuel-code       = goods.gds-code
    tt-rep.gds-name        = goods.gds-name
    tt-rep.volume          = tran-fuel.volume
    tt-rep.price           = tran-fuel.price
    tt-rep.money           = tran-fuel.money
    tt-rep.datetime-beg    = vDateBeg
    tt-rep.date-beg        = date(vDateBeg)
    tt-rep.time-beg        = mtime(vDateBeg) / 1000
    tt-rep.datetime-end    = vDateEnd
    tt-rep.date-end        = date(vDateEnd)
    tt-rep.time-end        = mtime(vDateEnd) / 1000
    tt-rep.time-length     = (vDateEnd - vDateBeg) / 1000
    tt-rep.all-time-length = tt-rep.time-length
    tt-rep.multi-pay       = no
    tt-rep.resume-tran     = no
    tt-rep.uuid            = tran-fuel.uuid
    tt-rep.uuid-cheq       = tran-fuel.uuid-cheq
    tt-rep.db-num          = tran-fuel.db-num
  .
  if tt-rep.uuid-cheq = "" then do:
     vCount = vCount + 1.
     tt-rep.uuid-cheq = "empty-" + string(vCount, "99999999").
  end.
end.