/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

получение атрибута доступности БД для записи

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/20/06
Author: Dmitry Ukhanov
Creation date: 04/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure get-ro_get-read-only :

  define output parameter p-ro-set as logical   no-undo .

  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info{&vssseq}, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info{&vssseq} )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.

end procedure. /* get-ro_get-read-only */

/* $Workfile$ e n d */