block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

инициализация глобальных переменных автоматической системы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .

/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
/*В ЭТОМ ФАЙЛЕ НЕДОПУСТИМО ИСПОЛЬЗОВАТЬ ССЫЛКИ НА КАКУЮ-ЛИБО БАЗУ ДАННЫХ*/
/*Т.Е. ЭТОТ ФАЙЛ ДОЛЖЕН КОМПИЛЛИРОВАТЬСЯ БЕЗ БД*/
/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "инициализация глобальных переменных автоматической системы".
{ cmp/vssrevis.i }
&glob defonly yes
{ adm/auto-def.i }

do
on error undo, return error return-value
:
  /* запомним имя пользователя и пароль */
  assign
    g#auto-user-login    = p-user-login
    g#auto-user-password = p-user-password
  .

  run GetCurrentProcessID (output g#auto-pid) .
end.

PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll" :
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.

/* $Workfile$  end */