/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Преобразование различных форматов дат

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/03/05
Author: Bakhtadze Natalya
Creation date: 03/03/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob enabled-windows-date-formats "dd.mm.yyyy" + ~{&comma-char~} + ~
                                   "dd.mm.yy" + ~{&comma-char~} + ~
                                   "dd.m.yyyy" + ~{&comma-char~} + ~
                                    "dd/mm/yy" + ~{&comma-char~} + ~
                                    "yyyy-mm-dd"


&glob default-windows-date-format   "dd.mm.yyyy"

function windows-date-format returns character ( input p-date  as date, input p-format as character ):
define variable v-string-date as character no-undo .
CASE p-format:
  when "dd.mm.yyyy":U
  or
  when "dd.mm.yy":U
  or
  when "dd/mm/yy":U
  then do:
    assign
    p-format = replace(p-format, "dd", "99")
    p-format = replace(p-format, "mm", "99")
    p-format = replace(p-format, "yy", "99")
    v-string-date = string(p-date, p-format)
    .
  end.
  when "d.m.yy":U then do:
    ASSIGN
    v-string-date = string(day(p-date), ">9") + string(month(p-date), ">9") +
                    substring(string(p-date, "99/99/99"), 7, 2)
    .
  end.
  when "yyyy-mm-dd":U then do:
    ASSIGN
    v-string-date = string(year(p-date), "9999") + "-":U + string(month(p-date), "99") + string(day(p-date), "99")
    .
  end.
END CASE.
return v-string-date.
END FUNCTION.

/* $Workfile$ e n d */
