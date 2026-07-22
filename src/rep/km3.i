/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение темп-таблицы для КМ-3

Автор: Комаров Иван Сергеевич
Дата создания: 21/10/09
Author: Ivan Komarov
Creation date: 21/10/09

Автор1: Белоусов Илья Александрович

*/

define buffer buf_tt-cash-desk for tt-cash-desk.
foreach:
for each buf_chk-doc where buf_chk-doc.obj-type  = {&shop}
                        and buf_chk-doc.obj-code  = tt-cash-desk.obj-code
                        and ( buf_chk-doc.shift-date >= x-date-start
                         or buf_chk-doc.chk-date     >= x-date-start )
                        and ( buf_chk-doc.shift-date <= x-date-end
                           or buf_chk-doc.chk-date   <= x-date-end )
                        and (buf_chk-doc.chk-type  = integer({&rcpt-return})
                           or buf_chk-doc.chk-type  = integer({&rcpt-return-write-off})
                              )
                             no-lock
                         :
  if X-tog-shift then do:
    if is-doc then do:
     if buf_chk-doc.shift-date <> x-date-start
     or buf_chk-doc.shift-num <> x-shift-alone then next.
    end .
    else do :
      if (buf_chk-doc.shift-date = x-date-start and buf_chk-doc.shift-num < x-shift-start
      or buf_chk-doc.shift-date = x-date-end   and buf_chk-doc.shift-num > x-shift-end)
      then next.
     end .
   end .
  else do:
     if ( buf_chk-doc.chk-date < x-date-start
       or buf_chk-doc.chk-date > x-date-end )
       then next.
      end .
  if is-doc then do:
    find first buf_tt-cash-desk where
              buf_tt-cash-desk.cash-num = buf_chk-doc.pay-desk
          and buf_tt-cash-desk.obj-code = buf_chk-doc.obj-code no-error.
    if not available buf_tt-cash-desk then next.
  end .

  find first buf_clients where buf_clients.obj-code = buf_chk-doc.cashier-psn-code
                          and buf_clients.obj-type = {&prs}
                          no-lock
                      no-error
                      .
  if available buf_clients then v-person = buf_clients.obj-name.
                            else v-person = "Кассир №" + string ( buf_chk-doc.cashier ) .

  find first buf_person no-lock
        where buf_person.psn-code = buf_chk-doc.cashier-psn-code
        no-error .
  if available buf_person
  then do :
    v-person = buf_clients.obj-name.
  end .
  for each buf_chk-pay no-lock
        where buf_chk-pay.doc-code = buf_chk-doc.doc-code :
    find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code   and
                                       buf_cash-pay-attr.curr-code  = buf_chk-pay.curr-code  and
                                       buf_cash-pay-attr.attr-code  = "form_km3" no-lock no-error.
    if available buf_cash-pay-attr and buf_cash-pay-attr.attr-value = "yes" then
      assign
        v-chk-tot = v-chk-tot + buf_chk-pay.tot-rubl
      .
  end.
  if v-chk-tot = 0 then next foreach.
  assign
  v-chk-tot = 0 - v-chk-tot
  .

  assign
  v-is-petrol     = no
  v-is-pieces     = no
  v-have-petrol   = no
  v-have-pieces   = no
  v-have-servise  = no
  .
  for each buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code
              no-lock
              :
    for first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code, first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code
                    :
      if buf_goods.gds-type = {&gds-office} then do :
        assign
        v-have-servise = yes
        .
      end .
      else do :
        { str/is-petrl.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        v-is-petrol
        v-is-pieces
        }
        if v-is-petrol = yes then v-have-petrol = yes.
        if v-is-pieces = yes then v-have-pieces = yes.
      end .
    end .
  end .

  create temp-str .
  if v-have-pieces = yes then do :
    assign temp-str.section-name  = temp-str.section-name + (if temp-str.section-name > '' then ',' else '') + 'ТНП'.
  end .
  if v-have-petrol = yes then do :
    assign temp-str.section-name  = temp-str.section-name + (if temp-str.section-name > '' then ',' else '') + 'Нефтепродукты'.
  end .
  if v-have-servise = yes then do :
    assign temp-str.section-name  = temp-str.section-name + (if temp-str.section-name > '' then ',' else '') + 'Услуги'.
  end .
  if v-have-pieces = no and v-have-petrol = no and v-have-servise = no then do :
    assign
    temp-str.section-name  = "Не определен"
    .
  end .
  assign
  temp-str.num-pos       = v-counter
  temp-str.chk-num       = buf_chk-doc.chk-num
  temp-str.chk-tot       = v-chk-tot
  temp-str.person        = v-person
  temp-str.shift-num     = buf_chk-doc.shift-num  /*shift-name-no-err(buffer buf_chk-doc)*/
  temp-str.cash-num      = buf_chk-doc.pay-desk
  temp-str.obj-code      = buf_chk-doc.obj-code
  temp-str.chk-date      = buf_chk-doc.chk-date
  temp-str.shift-date    = buf_chk-doc.shift-date
  v-chk-tot              = 0.0
  v-counter              = v-counter + 1
  .
  release temp-str .
end. /* EACH buf_chk-doc chk-date */


/* $Workfile$   E n d */