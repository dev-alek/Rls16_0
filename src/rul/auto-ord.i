/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

библиотека процедур для автозаказов

Автор: Мазуров Виталий Александрович
Дата создания: 19/09/11
Author: Vitaliy Mazurov
Creation date: 19/09/11

*/

&scop  start-proc do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*просматриваем список шаблонов*/
_buf_dis-some-rule:
for each buf_dis-some-rule no-lock
where buf_dis-some-rule.classif-type = "auto-ord-{1}" /*для правила Объект-Поставщик*/
:
    /*пропускаем, если шаблон не глобальный и клиент из списка не принадлежит фирме шаблона*/
    if buf_dis-some-rule.host-code > 0 and not get-host-true( buf_dis-some-rule.host-code, entry(v-i, v-clients, {&delim-par}) ) then next _buf_dis-some-rule .
    /*пропускаем, если шаблон объектный и клиент из списка не соответствует объекту шаблона*/
    if buf_dis-some-rule.obj-code > 0 and
    not buf_dis-some-rule.obj-type + string(buf_dis-some-rule.obj-code) = entry(v-i, v-clients, {&delim-par}) then next _buf_dis-some-rule .
    /*пропускаем, если сегодня не входит в расписание шаблона*/
    if not get-period-true( buf_dis-some-rule.charkey_three, entry(4, buf_dis-some-rule.charkey_two, chr(3) ), buf_dis-some-rule.rl-root ) then next _buf_dis-some-rule .

    /*это нужно для qntysale.p/qnty-obj.p*/
    for each obj-list exclusive-lock:
       delete obj-list .
    end.
    create obj-list .
    assign
      obj-list.obj-code = int(substring( entry(v-i, v-clients, {&delim-par}), 4 ))
      obj-list.obj-type = substring( entry(v-i, v-clients, {&delim-par}), 1, 3 )
    .

    /*расчитываем период расчета для метода расчета*/
    assign v-method = buf_dis-some-rule.charkey_one .
    run check-dates-method in this-procedure ( buf_dis-some-rule.key#_one,
                                               buf_dis-some-rule.key#_two,
                                               input-output v-method ) .
    /*собственно создаем заказ*/
    run cus/cr-zakaz.p (
      input parparentproc
    , input p-log-handle
    , input buf_dis-some-rule.key#_one                               /* дней до поставки */
    , input buf_dis-some-rule.key#_two                               /* дней продажи */
    , input entry(2, buf_dis-some-rule.charkey_two, chr(3) )         /* группа товаров */
    , input v-method                                                 /* метод расчета из ord-m-a.w */
    , input entry(1, buf_dis-some-rule.charkey_two, chr(3) )         /* отправлять во внешние системы? */
    , input if num-entries (buf_dis-some-rule.charkey_two, chr(3)) < 7 then "no" else entry(7, buf_dis-some-rule.charkey_two, chr(3) )         /* удалять нулевые позиции? */
    , input if num-entries (buf_dis-some-rule.charkey_two, chr(3)) < 7 then "no" else entry(6, buf_dis-some-rule.charkey_two, chr(3) )         /* добавлять товары только с артикулом поставщика? */
    , input int(substring( entry(3, buf_dis-some-rule.charkey_two, chr(3) ), 4 ))         /* код поставщика */
    , input substring( entry(3, buf_dis-some-rule.charkey_two, chr(3) ), 1, 3 )           /* тип поставщика */
    , input if num-entries (buf_dis-some-rule.charkey_two, chr(3)) < 7 then 0 else integer(entry(5, buf_dis-some-rule.charkey_two, chr(3) ))  /* код договора */
    , input int(substring( entry(v-i, v-clients, {&delim-par}), 4 )) /* код объекта */
    , input substring( entry(v-i, v-clients, {&delim-par}), 1, 3 )   /* тип объекта */
    , {2}
    ) no-error .

end. /*for each buf_dis-some-rule*/

/* $Workfile$ e n d */