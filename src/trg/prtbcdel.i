/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/03/03
Author: Bakhtadze Natalya
Creation date: 11/03/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure is-prt-bar-code :
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-node-code like ub.bar-code.node-code no-undo .
define input parameter p-part-code like ub.bar-code.part-code no-undo .
define input parameter p-in-code    like ub.bar-code.in-code no-undo .
define input parameter p-unit-cli   like ub.bar-code.unit-cli no-undo .
define output parameter p-is as logical no-undo .
define variable vss-description as character no-undo init "is-prt-bar-code-01: определяет является ли бар-код бар-кодом признака".

  do
  on error undo, return error
  :

    define buffer buf_gds-prt for ub.gds-prt.
    define buffer root_gds-prt for ub.gds-prt.

    find first buf_gds-prt no-lock where
               buf_gds-prt.node-code = p-node-code  no-error .

    if not available buf_gds-prt then do:
      return error substitute( "&1. Не найден узел шкалы для бар-кода &2", vss-workfile, string(p-b-code) ).
    end.


    find first root_gds-prt no-lock where
               root_gds-prt.prt-root = buf_gds-prt.prt-root
          AND  root_gds-prt.root     = yes no-error .
    if not avail root_gds-prt
    or root_gds-prt.node-name = {&empty-scale}
    then do:
      return error substitute( "&1. Узел шкалы для бар-кода &2, относится к <ПУСТОЙ ШКАЛЕ>", vss-workfile, string(p-b-code) ).
    end.

    if p-in-code <> "":u
    and root_gds-prt.root = yes
    then do:
      return error substitute( "&1. Бар-код &2, является бар-кодом ПАРТИИ", vss-workfile, string(p-b-code) ).
    end.

    assign
    p-is = yes
    .
    return "":U.
  end.

end procedure. /* is-prt-bar-code */


procedure is-part-bar-code :
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-node-code like ub.bar-code.node-code no-undo .
define input parameter p-part-code like ub.bar-code.part-code no-undo .
define input parameter p-in-code    like ub.bar-code.in-code no-undo .
define input parameter p-unit-cli   like ub.bar-code.unit-cli no-undo .

define output parameter p-is as logical no-undo .
define variable vss-description as character no-undo init "is-part-bar-code-01: определяет является ли бар-код партионным".

  do
  on error undo, return error
  :
    define buffer buf_gds-prt for ub.gds-prt.

    find first buf_gds-prt no-lock where
               buf_gds-prt.node-code = p-node-code  no-error .

    if not available buf_gds-prt
    then do:
      return error substitute( "&1. Не найден узел шкалы для бар-кода &2", vss-workfile, string(p-b-code) ).
    end.

    /* определяем бар-код партионный или нет */
    if p-in-code = "":U then do:
      return error substitute( "&1. Бар-код &2, относится НЕ к <ПАРТИИ>", vss-workfile, string(p-b-code) ).
    end.
    if buf_gds-prt.root <> yes
    then do:
      return error substitute( "&1. Узел шкалы для бар-кода &2, не является корневым", vss-workfile, string(p-b-code) ).
    end.
    assign
    p-is = yes
    .
    return "":U.
  end.

end procedure. /* is-part-bar-code */


procedure is-ucli-bar-code :
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-node-code like ub.bar-code.node-code no-undo .
define input parameter p-part-code like ub.bar-code.part-code no-undo .
define input parameter p-in-code    like ub.bar-code.in-code no-undo .
define input parameter p-unit-cli   like ub.bar-code.unit-cli no-undo .
define input parameter p-gds-code like ub.bar-code.gds-code no-undo .
define output parameter p-is as logical no-undo .
define variable vss-description as character no-undo init "is-ucli-bar-code-01: определяет является ли бар-код бар-кодом на доп.ед.изм.".

  do
  on error undo, return error
  :

    define buffer buf_goods for ub.goods.

    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code no-error .

    if not available buf_goods then do:
      return error substitute( "&1. Не найден товар для бар-кода &2", vss-workfile, string(p-b-code) ).
    end.
    if buf_goods.unit-base = p-unit-cli then do:
      return error substitute( "&1. Бар-код &2, относится к осн ед.изм.: осн.ид.изм. &3, ед.изм.бар-кода &4", vss-workfile, string(p-b-code), buf_goods.unit-base, p-unit-cli).
    end.
    assign
    p-is = yes
    .
    return "":U.
  end.

end procedure. /* is-prt-bar-code */


/* $Workfile$ e n d */