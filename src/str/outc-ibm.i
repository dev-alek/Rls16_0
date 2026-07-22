/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса IBM NKT-IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if {&cd-buffer}.cash-os = ""
AND {&cd-buffer}.pos-type <> {&cd-type-nkt-ibm}
then NEXT.
assign
Cash-OS2 = ({&cd-buffer}.cash-os = "OS/2":U) OR ({&cd-buffer}.cash-os = "LINUX":U)
            AND {&cd-buffer}.pos-type <> {&cd-type-nkt-ibm}
Cash-DOS = NOT CASH-OS2
fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 )
v-dir-remote-tmp = v-remote + "tmp":U
v-dir-remote = v-remote + "out":U + string({&cd-buffer}.obj-code, "99999") + "-" + string({&cd-buffer}.cash-num, "999")
.
if {&cd-buffer}.remote = 1 then do:
  run gbl/dir-cre.p ( input v-dir-remote-tmp) no-error .
    if error-status:error then do:
      /*директории нет и не удалось создать*/
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote-tmp
                            ,{&cd-buffer}.cash-num
                            ,{&new-line}
                            )
                                            ).
      NEXT.
  end.
  run gbl/dir-cre.p ( input v-dir-remote ) no-error .
    if error-status:error then do:
      /*директории нет и не удалось создать*/
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote
                            ,{&cd-buffer}.cash-num
                            ,{&new-line}
                            )
                                            ).
      NEXT.
    end.
end.
output stream IBMStream
to value( (if {&cd-buffer}.remote = 1
            then (v-dir-remote-tmp + {&slash-char} + "fl":U)
            else out) + fname + '.dat' ) convert target "ibm866".
OS2-time =       ( if Cash-OS2 then
                                    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
                      else "" )
.

/* $Workfile$ e n d */