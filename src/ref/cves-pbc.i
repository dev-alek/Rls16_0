/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание весового кода на товар по необходимости

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

если весовой код уже есть то он не создаетс
требует определения буфера
и известного на момент вызова основного корневого бар-кода {1}
и буфера товара {3}
def buffer for-pbc for prod-bc.
{2} - метка куда откатитьс

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-rid{&vssseq} as recid no-undo .

v-found = no.

/*Блокирование процесса вкл/выкл лок весовых кодов*/
{ trg/locklscc.i }

/*хотим узнать есть глоб или локальный но включенный */
if lookup({&weight}, {7}) > 0 then do:
  run trg/isvescod.p ( input {1}.b-code
                      ,input yes
                      ,input no
                      ,input yes
                      ,input ""
                      ,output v-found
                      ,output v-on
                      ,output v-b-str) no-error.
end.
else do:
  run trg/ispgwcod.p (input {1}.b-code
                    ,input yes /*p-question-pgweight*/
                    ,input no /*p-question-global*/
                    ,input yes /*p-question-on*/
                    ,input ""
                    ,output v-found
                    ,output v-on
                    ,output v-b-str ) no-error.

end.
if error-status:error then do:
  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
end.

/*весовой код уже был - попробуем включить обратно*/
if v-found and v-on = no then do:
  find first ub.prod-bc exclusive-lock where
             ub.prod-bc.b-code = {1}.b-code
        AND  ub.prod-bc.b-str = v-b-str no-error no-wait.
  if not avail prod-bc then do:
    assign
    v-found = no
    .
  end.
  else do:
    if prod-bc.bc-on = no then do:
      run trg/bc-upd.p (
                               input parparentproc
                ,input {1}.b-code
                ,input  ub.prod-bc.b-str
                ,input yes /*включить*/
                ,input yes /*mute*/
                ,input no /*sedn-ref*/
                ,input ?
                ,input ?
                ) no-error.
      if error-status:error then do:
        assign
        v-found = no
        .
      end.
    end.  /*if prod-bc.bc-on = no*/
  end. /*avail prod-bc*/
end. /*if v-found and v-on = no */

/*проверка наличия gds-obj на текущем объекте и его создания при необходимости*/
{ gbl/gdsobjcr.i {4} {5}  {3}.artic {3}.prod-type {3}.prod-code ub.gds-obj no-error }
release ub.gds-obj.
if lookup({&weight}, {7}) = 0
or v-found = yes
then do:
  /*проверим что нет*/
  define variable v-exist{&vssseq} as logical no-undo .
  run gdsoattr-exist in this-procedure (
                                        input {3}.gds-code
                                       ,input {4}
                                       ,input {5}
                                       ,input {&attr-scales-code-o}
                                       ,output v-exist{&vssseq}
                                      ) .
  if not v-exist{&vssseq} then do:
  { gbl/sclcdatr.i {3}.gds-code {4} {5} v-b-str no no-error }
end.
if error-status:error then do:
  return error '':U.
end.
end.
if not v-found
and lookup({&weight}, {7}) > 0
then do:
  v-rid{&vssseq} = ?.
  run trg/prod-bc1.p ( input parparentproc
                      ,input yes /*p-silent*/
                      ,input ? /* dif-pdbc */
                      ,input ? /*pbc-veto*/
                      ,input no /*send-ref*/
                      ,input {&loc-sc-code}
                      ,input "" /*p-ean-type*/
                      ,buffer {3}
                      ,input {1}.b-code
                      ,input-output v-b-str /*p-b-str*/
                      ,output v-rid{&vssseq}
                      ) no-error.
  if error-status:error
  or v-rid{&vssseq} = ? then do:
    return error substitute("Ошибка при сохранении ДопБК для весов&2&1&2&3", error-status:get-message(1) , {&new-line}, return-value ).
  end.
  find first prod-bc exclusive-lock where
            recid(prod-bc) = v-rid{&vssseq}.
    /*создание атрибута товара на объекте ВЕСОВОЙ код*/
end.

/* $Workfile$ e n d */