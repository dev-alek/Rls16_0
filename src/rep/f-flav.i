/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
FUNCTION n-lavel RETURNS char (INPUT grp-name as char, INPUT lavel# as int ).
define variable  str  as char format "X(60)"  no-undo.
define variable  str2 as char no-undo.
define variable v-r as character no-undo init "" .
define variable  i#i as int no-undo.

STR = "".

repeat i#i =1 to lavel#:
    if i#i =1 then str   = entry(1,grp-name, {&delim-grp}) .
    else do:
        str2 = entry(i#i,grp-name, {&delim-grp}) no-error.
        if not error-status:error  and str2 <> "":u then
               str = str +  {&delim-grp} +  entry(i#i,grp-name, {&delim-grp}) no-error .
        end.
end.
if str <> ? then do:
v-r = str + {&delim-grp} .
end.
RETURN v-r .
END FUNCTION.
/* $Workfile$ e n d */