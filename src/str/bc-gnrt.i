/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура формирования бар-кода

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/01
Author: Dmitry Ukhanov
Creation date: 04/12/01

*/
/*
{1} - new или ""
{2} - bc - для формирования собственного бар-кода, pl - для бар-кода складского места
*/

def {1} shared var {2}-frmt as character no-undo .
def {1} shared var {2}-pfx  as character no-undo .

def var {2}-par-type as character no-undo .

&if "{1}" = "new" &then
    run gbl/conf-rd.p ("{2}-frmt", "", "", 0, "", "", "", &if "{1}" = "bc" &then yes &else no &endif, output {2}-frmt, output {2}-par-type) no-error.
    if "{1}" = "bc" AND ( error-status:error OR {2}-par-type <> "C":U OR not can-do ("EAN8,EAN13", {2}-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.

    run gbl/conf-rd.p ("{2}-pfx", "", "", 0, "", "", "", &if "{1}" = "bc" &then yes &else no &endif, output {2}-pfx, output {2}-par-type) no-error.
    if "{1}" = "bc" AND ( error-status:error OR {2}-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
&endif

PROCEDURE gen-{2}:

  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .

{ str/bc-gnrti.i "{2}" "internal-b-code" "full-b-code" }
END PROCEDURE.