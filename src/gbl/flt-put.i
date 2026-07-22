/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись фильтров во временные файлы

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop seq {&sequence}

define variable v-flt-put-ind{&seq} as integer   no-undo .
define variable v-flt-put-ind-sort{&seq} as integer   no-undo .


output to value(string(g#report-num) + ".whr").
put .
if num-entries({1}filter.where-ysl) > 0 then do:
   put unformatted 'and ('.
   do v-flt-put-ind{&seq} = 1 to num-entries({1}filter.where-ysl):
     put unformatted entry(v-flt-put-ind{&seq}, {1}filter.where-ysl) skip.
   end.
   put unformatted ')'.
end.
output close.

output to value(string(g#report-num) + ".srt").
put .
do v-flt-put-ind{&seq} = 1 to num-entries({1}filter.fields-sort):
   if  entry(v-flt-put-ind{&seq}, {1}filter.fields-sort) <> "" then do:
       do v-flt-put-ind-sort{&seq} = 1 to num-entries(entry(v-flt-put-ind{&seq}, {1}filter.fields-sort),'*'):
            put  unformatted " by " + entry(v-flt-put-ind-sort{&seq},entry(v-flt-put-ind{&seq}, {1}filter.fields-sort),'*').
            if entry(v-flt-put-ind{&seq}, {1}filter.lst-cend) = '1' then put " descending".
        end.
   end.
end.
output close.

/* $Workfile$ e n d */