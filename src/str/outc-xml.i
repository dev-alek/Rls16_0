/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока для касс XML IBM и MAGIA данные по объекту

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("{&out-title}" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
&if "{&subject}" = "file" &then
&else

&if "{&data-by}" = "object" &then
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... магазин: &1", i-obj-code )
                                      ).

assign
v-obj-list = {&shop} + string(i-obj-code)
.
&if "{&xml-cd-doc-name}" = "" &then
&glob xml-cd-doc-name 'data'
&endif
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
    , input {&xml-cd-doc-name}
    , input {&version-string}
    , input v-obj-list
    , input (
              (IF {&cd-buffer}.pos-type = {&cd-type-ibm-xml}
                then (if {&cd-buffer}.autonomy = integer({&cd-self})
                      then  ("маг" + string({&cd-buffer}.obj-code) + "_касса" + string({&cd-buffer}.cash-num))
                      else ("КМ" /* string({&cd-buffer}.cash-num) */ /*Баранов просит не посылать*/ )
                      )
                else ("маг" + string({&cd-buffer}.obj-code) +  "_касса" + string({&cd-buffer}.cash-num))
                )
            )
    , input (if {&cd-buffer}.autonomy = integer({&cd-self}) then no else yes)
).
&endif
&if "{&data-by}" = "db" &then
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... БД: &1", g#db-num )
                                      ).
assign
v-obj-list = "БД" + string(g#db-num)
.
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
&if "{&subject}"="db-object" &then
    , input (if {&cd-buffer}.pos-type = {&cd-type-IBM-XML}
             then "setup"
             else "data")
&else
    , input "data"
&endif
    , input {&version-string}
    , input v-obj-list
    , input (
              (IF {&cd-buffer}.pos-type = {&cd-type-ibm-xml}
                then (if {&cd-buffer}.autonomy = integer({&cd-self})
                      then  ("маг" + string({&cd-buffer}.obj-code) + "_касса" + string({&cd-buffer}.cash-num))
                      else ("КМ" /*+ string({&cd-buffer}.cash-num) */ /*Баранов просит не посылать*/  )
                      )
                else ("маг" + string({&cd-buffer}.obj-code) + "_касса" + string({&cd-buffer}.cash-num))
                )
            )
    , input yes
).
&endif

output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.
OS2-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9").

&endif


/* $Workfile$ e n d */