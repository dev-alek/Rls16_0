/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

блокировка директория спулов при чтении чеков с касс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/06
Author: Bakhtadze Natalya
Creation date: 02/02/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*каждый раз при чтении почты накладывается блок на ресурс {&gchk}                                 */
/*если файлы спулов для разных магазинов лежат в разных директориях,                               */
/*то достаточно заблокировать этот ресурс на объекте                                               */
/*если же файлы спулов могут лежать в одной директории - например одна касса на несколько магазинов*/
/*то необходимо заблокировать данный ресурс в пределах всей БД                                     */
define variable v-param-type{&vssseq} as character no-undo .
define variable v-value-character{&vssseq} as character no-undo .
define variable v-value-date{&vssseq} as date no-undo .
define variable v-value-decimal{&vssseq} as decimal no-undo .
define variable v-value-integer{&vssseq} as INTEGER no-undo .
define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
define variable v-tth{&vssseq} as handle no-undo .
define variable hnum{&vssseq} as logical no-undo .

run adm/shattri.p (
    input "get":U
    ,input  {&cmp}
    ,input  v-host-code
    ,input  {&attr-get-chk}
    ,input  {&attr-get-chk_hnum} /*p-param-code*/
    ,output v-value-character{&vssseq}
    ,output v-value-date{&vssseq}
    ,output v-value-decimal{&vssseq}
    ,output v-value-integer{&vssseq}
    ,output v-value-logical{&vssseq}
    ,output v-param-type{&vssseq}
    ,INPUT-OUTPUT table-handle v-tth{&vssseq}
    ) no-error .
IF not error-status:error then  do:
  assign
  hnum{&vssseq} = v-value-logical{&vssseq}
  .
end.
delete object v-tth{&vssseq}.
/*пока ограничимся одним условием для определения того*/
/*надо ли блокировать всеь объект или базу в целом*/
v-lock-global = hnum{&vssseq}.

define variable v-r-m as character no-undo .
run gbl/lock-prc.p
    (input {&lock-prc-get-chk}
    ,input (if v-lock-global then 0 else p-obj-code)    ,input 0
    ,input 0
    ,input (if v-lock-global then "" else p-obj-type)
    ,input ""
    ,input ""
    ,input (
            (if v-lock-global then "" else "Код объекта") + ",,," +
            (if v-lock-global then "" else "Тип объекта") +  ",,,Почта с касс"
           )
    ,input no
    ,buffer get-chk-lock_batchprocess
    ) no-error .
  if error-status :error then do:
&if "{1}" = "message" &then
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент уже читается почта с касс" skip
      return-value skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.
&else
  assign
  v-r-m = return-value .
run writelog in p-log-handle (
      input log-file-name
    , input 0
    , input  "&Dline"
                                  ).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "В данный момент уже читается почта с касс &1&2&3&4"
                        , p-obj-type
                        , p-obj-code
                        , {&new-line}
                        , v-r-m
                      )
                                  ).
run writelog in p-log-handle (
      input log-file-name
    , input 0
    , input  "&Dline"
                                  ).
   undo, return .
&endif
end.

/* $Workfile$ e n d */