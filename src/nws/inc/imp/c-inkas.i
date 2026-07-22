/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием истории продажи в новостях

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "c-inkas-pay" then do:
      create locb2-c-inkas-pay.
      { nws/impl-nws.i "c-inkas-pay" "locb2-" }
    end.
    when "c-inkas-pay-desk" then do:
      create locb2-c-inkas-pay-desk.
      { nws/impl-nws.i "c-inkas-pay-desk" "locb2-" }
    end.
    when "c-inkas-pay-wth" then do:
      create locb2-c-inkas-pay-wth.
      { nws/impl-nws.i "c-inkas-pay-wth" "locb2-" }
    end.
    when "c-sale-doc" then do:
      create locb2-c-sale-doc.
      { nws/impl-nws.i "c-sale-doc" "locb2-" }
    end.

    /* todo */
    /*удаление продажи есть процесс при котором чеки составляющие ее должны оставаться в таком состояние,*/
    /*в каком они были бы если бы продажи ВООБЩЕ НЕ БЫЛО!*/
    /*т.е. если это продажа пришедшая по новостям - то чеки должны быть удалены ВООБЩЕ*/
    /* атакуже должна быть удалена их история*/
    /*если это продажа текущей БД то чеки просто остаются непривязанными              */
    /*весь этот процесс происходит в delfsale.p                                       */
    /*так же обходимся с чеками МЦ  и АВТО док-ми МЦ                                  */

    otherwise do:
      message " nws/inc/imp/c-inkas.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error " nws/inc/imp/c-inkas.i: Не предусмотрен прием таблицы " + rec-name + {&new-line} + "в составе накладной".
    end.
  END CASE.
end.

if not available tb-c-inkas then do:
  create tb-c-inkas.
end.
buffer-copy wt-c-inkas to tb-c-inkas.
/* ------------------------------- inkas-pay ---------------------------------------------- */
for each buf_c-inkas-pay where buf_c-inkas-pay.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay.
end.
for each locb2-c-inkas-pay where locb2-c-inkas-pay.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay.
  buffer-copy locb2-c-inkas-pay to buf_c-inkas-pay.
end.
/* ------------------------------- inkas-pay-desk------------------------------------------ */
for each buf_c-inkas-pay-desk where buf_c-inkas-pay-desk.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay-desk.
end.
for each locb2-c-inkas-pay-desk where locb2-c-inkas-pay-desk.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay-desk.
  buffer-copy locb2-c-inkas-pay-desk to buf_c-inkas-pay-desk.
end.

/* ------------------------------- inkas-pay-wth------------------------------------------ */
for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay-wth.
end.
for each locb2-c-inkas-pay-wth where locb2-c-inkas-pay-wth.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay-wth.
  buffer-copy locb2-c-inkas-pay-wth to buf_c-inkas-pay-wth.
end.


/* ------------------------------- sale-doc ---------------------------------------------- */
for each buf_c-sale-doc where buf_c-sale-doc.inkas-code = wt-c-inkas.inkas-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-sale-doc.
end.
for each locb2-c-sale-doc where locb2-c-sale-doc.inkas-code = wt-c-inkas.inkas-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-sale-doc.
  buffer-copy locb2-c-sale-doc to buf_c-sale-doc.
end.


/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb2-c-inkas
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas.
end.
for each locb2-c-inkas-pay
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas-pay.
end.
for each locb2-c-inkas-pay-desk
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas-pay-desk.
end.
for each locb2-c-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-inkas-pay-wth.
end.
for each locb2-c-sale-doc
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-sale-doc.
end.


/* $Workfile$ e n d */