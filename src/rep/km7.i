/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение тела для КМ-7

Автор: Комаров Иван Сергеевич
Дата создания: 06/30/10
Author: Ivan Komarov
Creation date: 06/30/10

Автор1: Белоусов Илья Александрович

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

for each buf_chk-doc
    where buf_chk-doc.obj-type    = {&shop}
      and buf_chk-doc.obj-code    = This_Object.obj-code
      and (buf_chk-doc.shift-date = x-date-start
        or buf_chk-doc.chk-date   = x-date-start)
      and buf_chk-doc.pay-desk = buf_cash-desk.cash-num
          :
      if X-tog-shift then do :
        if buf_chk-doc.shift-num <> x-shift-alone then next.
      end.
      else do :
        if buf_chk-doc.chk-date <> x-date-start then next.
      end.
      if lookup(string(buf_chk-doc.chk-type), {&sale-in-receipt-codes}) > 0 then do :
          assign
            v-summ-return = v-summ-return + ABS(buf_chk-doc.netto)
          .
      end.
      find first temp-str
            where temp-str.cash-num = buf_chk-doc.pay-desk
            no-error.
          if available temp-str then do :
            if buf_chk-doc.z-number > temp-str.z-number then do :
              assign temp-str.z-number = buf_chk-doc.z-number .
            end.
          end.
          else do :
            CREATE temp-str. /*создаем новую запись в таблице*/
          assign
              temp-str.kkm-code-reg  = buf_cash-desk.registration-code
              temp-str.kkm-code-prod = buf_cash-desk.serial-code
              temp-str.cash-num      = buf_cash-desk.cash-num
              temp-str.z-number      = buf_chk-doc.z-number
          .
          end.
end. /*for each buf_chk-doc*/
find first temp-str  /*ищем номер предыдущего чека, если не было продаж*/
     where temp-str.cash-num = buf_cash-desk.cash-num
     no-error.
     if not available temp-str then do :
      find first buf_chk-doc
          where buf_chk-doc.obj-type    = {&shop}
            and buf_chk-doc.obj-code    = This_Object.obj-code
            and (buf_chk-doc.shift-date <= x-date-start
              or buf_chk-doc.chk-date   <= x-date-start)
            and buf_chk-doc.pay-desk    = buf_cash-desk.cash-num
            and buf_chk-doc.z-number    <> 0
            use-index shift no-error .
            if available buf_chk-doc then do :
                if X-tog-shift then do:
                  if ( buf_chk-doc.shift-num >= x-shift-alone
                    and buf_chk-doc.shift-date = x-date-start )
                    then next.
                end.
                else do :
                  if buf_chk-doc.chk-date >= x-date-start then next.
                end.
                create temp-str.
                assign
                  temp-str.kkm-code-reg  = buf_cash-desk.registration-code
                  temp-str.kkm-code-prod = buf_cash-desk.serial-code
                  temp-str.cash-num      = buf_cash-desk.cash-num
                  temp-str.z-number      = buf_chk-doc.z-number
                .
            end.
     end.
release temp-str.
/* $Workfile$   E n d */