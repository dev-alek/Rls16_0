/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Абсолютно необходимые утилиты для определения контекста

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/19/09
Author: Bakhtadze Natalya
Creation date: 01/19/09

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


PROCEDURE get-db-num :
  define output parameter p-db-num as integer no-undo .
  do
  on error undo, return error return-value
  :
      run gbl/getdbnum.p (output p-db-num).
  end. /*doe*/


END PROCEDURE.

define variable v-cntxa-report-num as integer no-undo .
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error
  :
    if v-cntxa-report-num = 0 then do:
      run gbl/getrpnum.p (output p-report-num).
      v-cntxa-report-num = p-report-num.
    end.
    else do:
      assign
      p-report-num = v-cntxa-report-num
      .
    end.
  end.

END PROCEDURE.


PROCEDURE get-userid :
do
on error undo, return error
:
define output parameter p-userid  as character    no-undo.

    assign
        p-userid = g#userid
    .
end.
END PROCEDURE.

PROCEDURE get-version-num :
define output parameter p-curr-version as character no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/getvern.p
      ( output p-curr-version
      ) .
  end.

END PROCEDURE.


procedure get-news :
define output parameter p-news as logical no-undo .

  do
  on error undo, return error
  :
     p-news = g#news.
  end.

end procedure. /* get-news */


procedure get-esys :
define output parameter p-esys as logical no-undo .

  do
  on error undo, return error
  :
     p-esys = g#esys.
  end.

end procedure. /* get-news */


/* $Workfile$ e n d */