/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вспомогательные процедуры для onlinebkp

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/23/06
Author: Dmitry Ukhanov
Creation date: 06/23/06

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }

procedure check-need-onlinebkp :

  define output parameter p-need-bkp as logical   no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :
    define variable v-run-bkp-str as character no-undo .

    get-key-value section "onlinebkp"
                      key "run-bkp"
                    value v-run-bkp-str.

    if v-run-bkp-str = ?
      or CAPS( v-run-bkp-str ) = "FALSE":U
      or CAPS( v-run-bkp-str ) = "NO":U
    then do:
      assign
        p-need-bkp = false
      .
    end.
    else do:
      assign
        p-need-bkp = true
      .
    end.

    return .

  end.

end procedure. /* check-need-onlinebkp */
/* $Workfile$ e n d */