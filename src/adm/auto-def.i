/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение глобальных переменных для системы передачи новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

/* В ЭТОМ ФАЙЛЕ НЕДОПУСТИМО ИСПОЛЬЗОВАТЬ ССЫЛКИ НА КАКУЮ-ЛИБО БАЗУ ДАННЫХ!!! */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(auto-def_i) = 0 &then
&glob auto-def_i yes
define {1} shared variable g#auto-pid           as integer   no-undo .
define {1} shared variable conn-par             as character no-undo .
define {1} shared variable g#auto-user-id       as character no-undo .
define {1} shared variable g#auto-user-login    as character no-undo .
define {1} shared variable g#auto-user-password as character no-undo .
define {1} shared variable v-socket             as logical   no-undo .

{adm/auto-def-log.i {1}}
&endif

/* $Workfile$ e n d */