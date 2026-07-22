/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание должности с указанием подразделения или уровня -

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/05/06
Author: Bakhtadze Natalya
Creation date: 07/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*найти описание должности с указанием подразделения или уровня - т.е. role + level-type + level +  */
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
&scop role-code p-role
&scop role-level-code p-role-level
assign
v-role-name = {&role-name}
v-role-level = substitute("&1 &2", {&role-level-name} , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then {&question-mark} else string(p-staff-code))).
END.


/* $Workfile$ e n d */