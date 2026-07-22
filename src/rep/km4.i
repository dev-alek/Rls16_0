/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение тела для КМ-4

Автор: Комаров Иван Сергеевич
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10

Автор1: Белоусов Илья Александрович
Дата создания1: 18.08.08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable chk-shift-open-time as logical no-undo init yes. /* если нету даты начала смены, то каждый раз обновляем время первого чека (да - если есть, нет - если нет)*/

for each buf_chk-doc
    where buf_chk-doc.obj-type    = {&shop}
      and buf_chk-doc.obj-code    = tt-cash-desk.obj-code
      and ((buf_chk-doc.shift-date = x-date-start and X-tog-shift)
        or (buf_chk-doc.chk-date   = x-date-start and not X-tog-shift))
      and buf_chk-doc.pay-desk    = tt-cash-desk.cash-num
      no-lock use-index shift
      :
      if X-tog-shift then do:
        if buf_chk-doc.shift-num <> x-shift-alone then next.
      end.
      else do :
        if buf_chk-doc.chk-date <> x-date-start then next.
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
          temp-str.cash-num      = tt-cash-desk.cash-num
          temp-str.z-number      = buf_chk-doc.z-number
          temp-str.zero-counter  = 0  /* ???? */
          temp-str.chk-num       = buf_chk-doc.chk-num
          temp-str.chk-shift-open-time = no.
        for first buf_shift-cash
           where buf_shift-cash.obj-type    = {&shop}
             and buf_shift-cash.obj-code    = tt-cash-desk.obj-code
             and buf_shift-cash.shift-date  = x-date-start
             and buf_shift-cash.shift-num   = x-shift-alone
             and buf_shift-cash.cash-num    = tt-cash-desk.cash-num
             :
                assign temp-str.chk-time-1 = buf_shift-cash.shift-open-time
                       temp-str.chk-time-2 = buf_shift-cash.shift-close-time.
                if temp-str.chk-time-1 <> 0 then do:
                    temp-str.chk-shift-open-time = yes.
                end.
        end.                   .
          end.

      if temp-str.chk-time-2 = 0 then do: /*если время не заполнено - получаем время последнего чека */
          assign temp-str.chk-time-2 = buf_chk-doc.chk-time.
      end.

      if temp-str.chk-shift-open-time = no then do: /*каждый раз обновляем время первого чека */
          assign temp-str.chk-time-1 = buf_chk-doc.chk-time.
      end.
      

      /* По продажам за наличные */
      if lookup(string(buf_chk-doc.chk-type), {&sale-out-receipt-codes}) > 0 then do :
          for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-doc.doc-code:
              
              if lookup(string(buf_chk-pay.pay-code), v-is-cash-list) > 0 then do:
                temp-str.summ-nal = temp-str.summ-nal + buf_chk-pay.tot-rubl.
              end.
              
              for first buf_chk-pay-attr where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                             and buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                                             and buf_chk-pay-attr.attr-code = "autotank-sum-return" no-lock:
                    temp-str.summ-nal = temp-str.summ-nal - decimal(buf_chk-pay-attr.attr-value).
                end.
              
              if not can-find(first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                         and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                         and buf_cash-pay-attr.attr-code = "kbo")
              and not can-find(first buf_cash-pay where buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
                                                    and buf_cash-pay.curr-code = buf_chk-pay.curr-code
                                                    and buf_cash-pay.is-service-pay = yes) then do:
                temp-str.summ-sale = temp-str.summ-sale + buf_chk-pay.tot-rubl.
                
                for first buf_chk-pay-attr where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                             and buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                                             and buf_chk-pay-attr.attr-code = "autotank-sum-return" no-lock:
                    temp-str.summ-sale = temp-str.summ-sale - decimal(buf_chk-pay-attr.attr-value).
                end.
                
              end.
          end.
      end.
      
      if lookup(string(buf_chk-doc.chk-type), {&sale-in-receipt-codes}) > 0 then do :
        for each buf_chk-pay no-lock
              where buf_chk-pay.doc-code = buf_chk-doc.doc-code :
          find first buf_cash-pay-attr where  buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code   and
                                              buf_cash-pay-attr.curr-code  = buf_chk-pay.curr-code  and
                                              buf_cash-pay-attr.attr-code  = "form_km3" no-lock no-error.
          if available buf_cash-pay-attr and buf_cash-pay-attr.attr-value = "yes" then
            assign
              temp-str.summ-return = temp-str.summ-return + ABS(buf_chk-pay.tot-rubl)
            .
        end.
      end.
      find first buf_sale-clients
            where buf_sale-clients.obj-code = buf_chk-doc.cashier-psn-code
              and buf_sale-clients.obj-type = {&prs}
              no-lock
              no-error.

              if available buf_sale-clients then do :
                assign
                    temp-str.person = buf_sale-clients.obj-name
                .
              end.
              else do:
                  assign
                    temp-str.person = " Кассир  № " + string ( buf_chk-doc.cashier )
                  .
              end.
end. /*for each buf_chk-doc*/
find first temp-str  /*ищем номер предыдущего чека, если не было продаж*/
     where temp-str.cash-num = tt-cash-desk.cash-num
     no-error.
     if not available temp-str then do :
      find first buf_chk-doc
          where buf_chk-doc.obj-type    = {&shop}
            and buf_chk-doc.obj-code    = tt-cash-desk.obj-code
            and (buf_chk-doc.shift-date <= x-date-start
              or buf_chk-doc.chk-date   <= x-date-start)
            and buf_chk-doc.pay-desk    = tt-cash-desk.cash-num
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
                  temp-str.cash-num = tt-cash-desk.cash-num
                  temp-str.z-number = buf_chk-doc.z-number
                .
            end.
     end.
release temp-str.
/* $Workfile$   E n d*/