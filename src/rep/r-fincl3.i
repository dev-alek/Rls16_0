/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временной таблицы отчета форма №3 взаиморасчет с контрагентами

Автор: Хныкин Павел Андреевич
Дата создания: 08/24/07
Author: Pavel Khnykin
Creation date: 08/24/07

{1} - таблица с контрагентами

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop wth-sum-type "":U
&scop wealth-serial 1

    _calc-block:
    for each {1} no-lock
    :
      if {1}.obj-type = {&shop} or {1}.obj-type = {&stock} then do:
        next _calc-block.
      end.
      assign
        v-repfrm-str  = "Расчет для: " + {1}.obj-name
        v-saldo-start = 0
        v-saldo-end   = 0
      .
      run waitfram-show in this-procedure ( input v-repfrm-str ).
      /* сальдо по клиенту на начало */
      run calc-cli-saldo in this-procedure ( input  {1}.obj-type
                                           , input  {1}.obj-code
                                           , input  v-cntxt-host-code-obj
                                           , input  v-curr-r-b
                                           , input  v-fact-order-start
                                           , output v-saldo-start
                                           ) .
      /* сальдо по клиенту на конец */
      run calc-cli-saldo in this-procedure ( input  {1}.obj-type
                                           , input  {1}.obj-code
                                           , input  v-cntxt-host-code-obj
                                           , input  v-curr-r-b
                                           , input  v-fact-order-end
                                           , output v-saldo-end
                                           ) .
      /* собираем информацию по талонам */
      run calc-talon-oborot in this-procedure ( input  {1}.obj-type
                                              , input  {1}.obj-code
                                              , input  v-cntxt-host-code-obj
                                              ) .
      /*.собираем финансовые поступления */
      run calc-fin-pri in this-procedure ( input  {1}.obj-type
                                         , input  {1}.obj-code
                                         , input  v-cntxt-host-code-obj
                                         ) .
      create tt-report-head.
      assign
        tt-report-head.obj-type = {1}.obj-type
        tt-report-head.obj-code = {1}.obj-code
        tt-report-head.obj-name = {1}.obj-name
      .
    end.
/* $Workfile$ e n d */