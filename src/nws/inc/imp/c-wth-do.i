/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием истории док-тов МЦ

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
    when "c-wth-line" then do:
      create locb-c-wth-line.
      { nws/impl-nws.i "c-wth-line" "locb-" }
    end.
    when "c-wth-dtl" then do:
      create locb-c-wth-dtl.
      { nws/impl-nws.i "c-wth-dtl" "locb-" }
    end.
    when "c-wth-parts" then do:
      create locb-c-wth-parts.
      { nws/impl-nws.i "c-wth-parts" "locb-" }
    end.
    when "c-inkas-pay-wth" then do:
      create locb2-c-inkas-pay-wth.
      { nws/impl-nws.i "c-inkas-pay-wth" "locb2-" }
    end.


    /*удаление АВТО док-тов МЦ - (а только такие документы МЦ содержат чеки МЦ*/
    /*есть процесс связанный с удалением продажи                            */
    /*А удаление продажи есть процесс при котором чеки составляющие ее должны оставаться в таком состояние,*/
    /*в каком они были бы если бы продажи ВООБЩЕ НЕ БЫЛО!*/
    /*т.е. если это продажа пришедшая по новостям - то чеки должны быть удалены ВООБЩЕ вместе с историей*/
    /*если это продажа текущей БД то чеки просто остаются непривязанными              */
    /*весь этот процесс происходит в delfsale.p                                       */
    /*так же обходимся с чеками МЦ  и АВТО док-ми МЦ                                  */
    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории документа мат. ценностей"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

if not available tb-c-wth-doc then do:
  create tb-c-wth-doc.
end.
buffer-copy wt-c-wth-doc to tb-c-wth-doc.
/* ------------------------------- c-wth-dtl ---------------------------------------------- */
for each buf_c-wth-dtl where buf_c-wth-dtl.doc-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-dtl.
end.
for each locb-c-wth-dtl where locb-c-wth-dtl.doc-code = wt-c-wth-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-dtl.
  buffer-copy locb-c-wth-dtl to buf_c-wth-dtl.
end.
/* ------------------------------- c-wth-line ---------------------------------------------- */
on delete of ub.c-wth-line override do: end.
for each buf_c-wth-line where buf_c-wth-line.doc-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-line.
end.
for each locb-c-wth-line where locb-c-wth-line.doc-code = wt-c-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-line.
  buffer-copy locb-c-wth-line to buf_c-wth-line.
end.
/* ------------------------------- c-wth-parts ---------------------------------------------- */
on delete of ub.c-wth-parts override do: end.
for each buf_c-wth-parts where buf_c-wth-parts.out-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-wth-parts.
end.
for each locb-c-wth-parts where locb-c-wth-parts.out-code = wt-c-wth-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-wth-parts.
  buffer-copy locb-c-wth-parts to buf_c-wth-parts.
end.

/* ------------------------------- inkas-pay-wth------------------------------------------ */
for each buf_c-inkas-pay-wth where buf_c-inkas-pay-wth.inkas-code = wt-c-wth-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-inkas-pay-wth.
end.
for each locbw2-c-inkas-pay-wth where locbw2-c-inkas-pay-wth.inkas-code = wt-c-wth-doc.doc-code
                        no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-inkas-pay-wth.
  buffer-copy locbw2-c-inkas-pay-wth to buf_c-inkas-pay-wth.
end.


/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb-c-wth-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-wth-line.
end.
for each locb-c-wth-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-wth-dtl.
end.
for each locb-c-wth-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-wth-parts.
end.
for each locbw2-c-inkas-pay-wth
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbw2-c-inkas-pay-wth.
end.


/* $Workfile$ e n d */