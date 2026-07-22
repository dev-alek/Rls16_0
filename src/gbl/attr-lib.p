block-level on error undo, throw.
/*
  
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека атрибутов

Автор: Перваков Михаил Сергеевич
Дата создания: 12/06/06
Author: Mikhail Pervakov
Creation date: 12/06/06

значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no
все форматирование осуществлять на верхнем уровне

глобальные определения названий атрибутов заводятся в s t r - g l b l . i


атрибуты клиентов
атрибуты объектов TH
атрибуты товаров
атрибуты бар-кодов
атрибуты касс
атрибуты товаров на объекте
атрибуты баз данных
атрибуты внешних систем
атрибуты группы товаров на объекте
атрибуты ассортиментных матриц
атрибуты свойств товара для заказа

	Last change:  NIA  21 Mar 2011    5:06 pm
*/

using ibs.th.gbl.gbl-hndllib from propath.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека  процедур".
{ cmp/vssrevis.i }
&global-define attr-lib
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/attr-lib.i }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ ref/grpobj.i   }
{ gbl/thbj-def.i }
{ rep/frmlib.i }
{ gbl/key-rec.i}

if valid-handle (g#attr-lib)
and g#attr-lib <> this-procedure :handle
and g#attr-lib :get-signature('attr-lib_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#attr-lib skip
    g#attr-lib :type skip
    g#attr-lib :file-name skip
    valid-handle(g#attr-lib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#attr-lib = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#attr-lib", g#attr-lib).
  delete object gbl-hndllibObj.
end.

if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.

on delete of this-procedure
do:
  assign
    g#attr-lib = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#attr-lib", g#attr-lib).
  delete object gbl-hndllibObj.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
end.

procedure attr-lib_testproc :

end.

/* ################## */
/* атрибуты клиентов  */

/* Дата с которой существуют документы */
&scop type-attr-doc-start-date {&type-date}
&scop format-attr-doc-start-date "99/99/9999"
&scop label-attr-doc-start-date "Дата с которой существуют документы"
&scop tooltip-attr-doc-start-date "Дата с которой существуют документы"
&scop user-can-edit-attr-doc-start-date false
&scop output-display-attr-doc-start-date true
&scop other-attr-doc-start-date '':u
&scop news-attr-doc-start-date false
&scop manual-edit-attr-doc-start-date  0
&scop batch-edit-attr-doc-start-date  0


/* Дата начала подробного складского архива по товарам */
&scop type-attr-arh-detail-date {&type-date}
&scop format-attr-arh-detail-date "99/99/9999"
&scop label-attr-arh-detail-date "Дата начала подробного складского архива по товарам"
&scop tooltip-attr-arh-detail-date "Дата начала подробного складского архива по товарам"
&scop user-can-edit-attr-arh-detail-date false
&scop output-display-attr-arh-detail-date true
&scop other-attr-arh-detail-date '':u
&scop news-attr-arh-detail-date false
&scop manual-edit-attr-arh-detail-date  0
&scop batch-edit-attr-arh-detail-date  0


/* Дата начала сжатого складского архива по товарам */
&scop type-attr-arh-start-date {&type-date}
&scop format-attr-arh-start-date "99/99/9999"
&scop label-attr-arh-start-date "Дата начала сжатого складского архива по товарам"
&scop tooltip-attr-arh-start-date "Дата начала сжатого складского архива по товарам"
&scop user-can-edit-attr-arh-start-date false
&scop output-display-attr-arh-start-date true
&scop other-attr-arh-start-date '':u
&scop news-attr-arh-start-date false
&scop manual-edit-attr-arh-start-date  0
&scop batch-edit-attr-arh-start-date  0


/* Дата начала подробного складского архива по поставщикам */
&scop type-attr-ahsp-detail-date {&type-date}
&scop format-attr-ahsp-detail-date "99/99/9999"
&scop label-attr-ahsp-detail-date "Дата начала подробного складского архива по поставщикам"
&scop tooltip-attr-ahsp-detail-date "Дата начала подробного складского архива по поставщикам"
&scop user-can-edit-attr-ahsp-detail-date false
&scop output-display-attr-ahsp-detail-date true
&scop other-attr-ahsp-detail-date '':u
&scop news-attr-ahsp-detail-date false
&scop manual-edit-attr-ahsp-detail-date  0
&scop batch-edit-attr-ahsp-detail-date  0


/* Дата начала сжатого складского архива по поставщикам */
&scop type-attr-ahsp-start-date {&type-date}
&scop format-attr-ahsp-start-date "99/99/9999"
&scop label-attr-ahsp-start-date "Дата начала сжатого складского архива по поставщикам"
&scop tooltip-attr-ahsp-start-date "Дата начала сжатого складского архива по поставщикам"
&scop user-can-edit-attr-ahsp-start-date false
&scop output-display-attr-ahsp-start-date true
&scop other-attr-ahsp-start-date '':u
&scop news-attr-ahsp-start-date false
&scop manual-edit-attr-ahsp-start-date  0
&scop batch-edit-attr-ahsp-start-date  0


/* Дата начала подробного складского архива по типам приобретения */
&scop type-attr-aht-detail-date {&type-date}
&scop format-attr-aht-detail-date "99/99/9999"
&scop label-attr-aht-detail-date "Дата начала подробного складского архива по типам приобретения"
&scop tooltip-attr-aht-detail-date "Дата начала подробного складского архива по типам приобретения"
&scop user-can-edit-attr-aht-detail-date false
&scop output-display-attr-aht-detail-date true
&scop other-attr-aht-detail-date '':u
&scop news-attr-aht-detail-date false
&scop manual-edit-attr-aht-detail-date  0
&scop batch-edit-attr-aht-detail-date  0


/* Дата начала сжатого складского архива по типам приобретения */
&scop type-attr-aht-start-date {&type-date}
&scop format-attr-aht-start-date "99/99/9999"
&scop label-attr-aht-start-date "Дата начала сжатого складского архива по типам приобретения"
&scop tooltip-attr-aht-start-date "Дата начала сжатого складского архива по типам приобретения"
&scop user-can-edit-attr-aht-start-date false
&scop output-display-attr-aht-start-date true
&scop other-attr-aht-start-date '':u
&scop news-attr-aht-start-date false
&scop manual-edit-attr-aht-start-date  0
&scop batch-edit-attr-aht-start-date  0


/* Удаление складского архива по товарам прошло с ошибкой */
&scop type-attr-arh-del {&type-log}
&scop format-attr-arh-del "+/"
&scop label-attr-arh-del "Удаление складского архива по товарам прошло с ошибкой"
&scop tooltip-attr-arh-del "Удаление складского архива по товарам прошло с ошибкой"
&scop user-can-edit-attr-arh-del false
&scop output-display-attr-arh-del true
&scop other-attr-arh-del '':u
&scop news-attr-arh-del false
&scop manual-edit-attr-arh-del  0
&scop batch-edit-attr-arh-del  0

/* Удаление складского архива по поставщикам прошло с ошибкой */
&scop type-attr-ahsp-del {&type-log}
&scop format-attr-ahsp-del "+/"
&scop label-attr-ahsp-del "Удаление складского архива по поставщикам прошло с ошибкой"
&scop tooltip-attr-ahsp-del "Удаление складского архива по поставщикам прошло с ошибкой"
&scop user-can-edit-attr-ahsp-del false
&scop output-display-attr-ahsp-del true
&scop other-attr-ahsp-del '':u
&scop news-attr-ahsp-del false
&scop manual-edit-attr-ahsp-del  0
&scop batch-edit-attr-ahsp-del  0


/* Удаление складского архива по типам приобретения прошло с ошибкой */
&scop type-attr-aht-del {&type-log}
&scop format-attr-aht-del "+/"
&scop label-attr-aht-del "Удаление складского архива по типам приобретения прошло с ошибкой"
&scop tooltip-attr-aht-del "Удаление складского архива по типам приобретения прошло с ошибкой"
&scop user-can-edit-attr-aht-del false
&scop output-display-attr-aht-del true
&scop other-attr-aht-del '':u
&scop news-attr-aht-del false
&scop manual-edit-attr-aht-del  0
&scop batch-edit-attr-aht-del  0


/* Расчет складского архива по товарам запрещен */
&scop type-attr-arh-disable {&type-log}
&scop format-attr-arh-disable "+/"
&scop label-attr-arh-disable "Расчет складского архива по товарам запрещен"
&scop tooltip-attr-arh-disable "Расчет складского архива по товарам запрещен"
&scop user-can-edit-attr-arh-disable false
&scop output-display-attr-arh-disable true
&scop other-attr-arh-disable '':u
&scop news-attr-arh-disable false
&scop manual-edit-attr-arh-disable  0
&scop batch-edit-attr-arh-disable  0


/* Расчет складского архива по поставщикам запрещен */
&scop type-attr-ahsp-disable {&type-log}
&scop format-attr-ahsp-disable "+/"
&scop label-attr-ahsp-disable "Расчет складского архива по поставщикам запрещен "
&scop tooltip-attr-ahsp-disable "Расчет складского архива по поставщикам запрещен "
&scop user-can-edit-attr-ahsp-disable false
&scop output-display-attr-ahsp-disable true
&scop other-attr-ahsp-disable '':u
&scop news-attr-ahsp-disable false
&scop manual-edit-attr-ahsp-disable  0
&scop batch-edit-attr-ahsp-disable  0


/* Расчет складского архива по типам приобретения запрещен  */
&scop type-attr-aht-disable {&type-log}
&scop format-attr-aht-disable "+/"
&scop label-attr-aht-disable "Расчет складского архива по типам приобретения запрещен"
&scop tooltip-attr-aht-disable "Расчет складского архива по типам приобретения запрещен"
&scop user-can-edit-attr-aht-disable false
&scop output-display-attr-aht-disable true
&scop other-attr-aht-disable '':u
&scop news-attr-aht-disable false
&scop manual-edit-attr-aht-disable  0
&scop batch-edit-attr-aht-disable  0


/* Первоначальный расчет складского архива по товарам */
&scop type-attr-arh-calc {&type-log}
&scop format-attr-arh-calc "+/"
&scop label-attr-arh-calc "Первоначальный расчет складского архива по товарам"
&scop tooltip-attr-arh-calc "Первоначальный расчет складского архива по товарам"
&scop user-can-edit-attr-arh-calc false
&scop output-display-attr-arh-calc true
&scop other-attr-arh-calc '':u
&scop news-attr-arh-calc false
&scop manual-edit-attr-arh-calc  0
&scop batch-edit-attr-arh-calc  0


/* Первоначальный расчет складского архива по поставщикам */
&scop type-attr-ahsp-calc {&type-log}
&scop format-attr-ahsp-calc "+/"
&scop label-attr-ahsp-calc "Первоначальный расчет складского архива по поставщикам"
&scop tooltip-attr-ahsp-calc "Первоначальный расчет складского архива по поставщикам"
&scop user-can-edit-attr-ahsp-calc false
&scop output-display-attr-ahsp-calc true
&scop other-attr-ahsp-calc '':u
&scop news-attr-ahsp-calc false
&scop manual-edit-attr-ahsp-calc  0
&scop batch-edit-attr-ahsp-calc  0


/* Первоначальный расчет складского архива по типам приобретени  */
&scop type-attr-aht-calc {&type-log}
&scop format-attr-aht-calc "+/"
&scop label-attr-aht-calc "Первоначальный расчет складского архива по типам приобретения"
&scop tooltip-attr-aht-calc "Первоначальный расчет складского архива по типам приобретени "
&scop user-can-edit-attr-aht-calc false
&scop output-display-attr-aht-calc true
&scop other-attr-aht-calc '':u
&scop news-attr-aht-calc false
&scop manual-edit-attr-aht-calc  0
&scop batch-edit-attr-aht-calc  0


/* по объекту происходит восстановление архива по товарам */
&scop type-attr-arh-rest {&type-log}
&scop format-attr-arh-rest "+/"
&scop label-attr-arh-rest "Восстановление архива по товарам прошло с ошибкой"
&scop tooltip-attr-arh-rest "Восстановление архива по товарам прошло с ошибкой"
&scop user-can-edit-attr-arh-rest false
&scop output-display-attr-arh-rest true
&scop other-attr-arh-rest '':u
&scop news-attr-arh-rest false
&scop manual-edit-attr-arh-rest  0
&scop batch-edit-attr-arh-rest  0


/* по объекту происходит восстановление архива по поставщикам */
&scop type-attr-ahsp-rest {&type-log}
&scop format-attr-ahsp-rest "+/"
&scop label-attr-ahsp-rest "Восстановление архива по поставщикам прошло с ошибкой"
&scop tooltip-attr-ahsp-rest "Восстановление архива по поставщикам прошло с ошибкой"
&scop user-can-edit-attr-ahsp-rest false
&scop output-display-attr-ahsp-rest true
&scop other-attr-ahsp-rest '':u
&scop news-attr-ahsp-rest false
&scop manual-edit-attr-ahsp-rest  0
&scop batch-edit-attr-ahsp-rest  0


/* по объекту происходит восстановление архива по типам приобретения */
&scop type-attr-aht-rest {&type-log}
&scop format-attr-aht-rest "+/"
&scop label-attr-aht-rest "Восстановлением архива по типам приобретения прошло с ошибкой"
&scop tooltip-attr-aht-rest "Восстановлением архива по типам приобретения прошло с ошибкой"
&scop user-can-edit-attr-aht-rest false
&scop output-display-attr-aht-rest true
&scop other-attr-aht-rest '':u
&scop news-attr-aht-rest false
&scop manual-edit-attr-aht-rest  0
&scop batch-edit-attr-aht-rest  0


/* Дата перерасчёта складского архива по товарам */
&scop type-attr-arh-recalc-date {&type-date}
&scop format-attr-arh-recalc-date "99/99/9999"
&scop label-attr-arh-recalc-date "Дата перерасчёта складского архива по товарам"
&scop tooltip-attr-arh-recalc-date "Дата перерасчёта складского архива по товарам"
&scop user-can-edit-attr-arh-recalc-date false
&scop output-display-attr-arh-recalc-date true
&scop other-attr-arh-recalc-date '':u
&scop news-attr-arh-recalc-date false
&scop manual-edit-attr-recalc-date  0
&scop batch-edit-attr-recalc-date  0


/* Дата перерасчёта складского архива по поставщикам */
&scop type-attr-ahsp-recalc-date {&type-date}
&scop format-attr-ahsp-recalc-date "99/99/9999"
&scop label-attr-ahsp-recalc-date "Дата перерасчёта складского архива по поставщикам"
&scop tooltip-attr-ahsp-recalc-date "Дата перерасчёта складского архива по поставщикам"
&scop user-can-edit-attr-ahsp-recalc-date false
&scop output-display-attr-ahsp-recalc-date true
&scop other-attr-ahsp-recalc-date '':u
&scop news-attr-ahsp-recalc-date false
&scop manual-edit-attr-recalc-date  0
&scop batch-edit-attr-recalc-date  0


/* Дата перерасчёта складского архива по типам приобретения */
&scop type-attr-aht-recalc-date {&type-date}
&scop format-attr-aht-recalc-date "99/99/9999"
&scop label-attr-aht-recalc-date "Дата перерасчёта складского архива по типам приобретения"
&scop tooltip-attr-aht-recalc-date "Дата перерасчёта складского архива по типам приобретения"
&scop user-can-edit-attr-aht-recalc-date false
&scop output-display-attr-aht-recalc-date true
&scop other-attr-aht-recalc-date '':u
&scop news-attr-aht-recalc-date false
&scop manual-edit-attr-recalc-date  0
&scop batch-edit-attr-recalc-date  0


/* организация инкассатор  */
&scop type-attr-is-inkassator {&type-log}
&scop format-attr-is-inkassator "+/"
&scop label-attr-is-inkassator "Организация-инкассатор"
&scop tooltip-attr-is-inkassator "Организация-инкассатор"
&scop user-can-edit-attr-is-inkassator  true
&scop output-display-attr-is-inkassator  true
&scop other-attr-is-inkassator  '':u
&scop news-attr-is-inkassator true
&scop manual-edit-attr-is-inkassator  1
&scop batch-edit-attr-is-inkassator  1


/* Вывод РАСХОДОВ отдельной строкой в листе 2 сменного отчета */
&scop type-attr-shftrep2 {&type-log}
&scop format-attr-shftrep2 "+/"
&scop label-attr-shftrep2 "РАСХОДЫ отдельной строкой"
&scop tooltip-attr-shftrep2 "Вывод РАСХОДОВ отдельной строкой в листе 2 сменного отчета"
&scop user-can-edit-attr-shftrep2  true
&scop output-display-attr-shftrep2  true
&scop other-attr-shftrep2 '':u
&scop news-attr-shftrep2 true
&scop manual-edit-attr-shftrep2  1
&scop batch-edit-attr-shftrep2  1


/* супервизор  */
&scop type-attr-is-superviser {&type-log}
&scop format-attr-is-superviser  "+/"
&scop label-attr-is-superviser   "Супервайзер"
&scop tooltip-attr-is-superviser   "Пользователь с правами супервайзера"
&scop user-can-edit-attr-is-superviser  true
&scop output-display-attr-is-superviser  true
&scop other-attr-is-superviser  '':u
&scop news-attr-is-superviser true
&scop manual-edit-attr-is-superviser  1
&scop batch-edit-attr-is-superviser  1


/* С клиентом работают в текущей БД */
&scop type-attr-db {&type-log}
&scop format-attr-db "+/"
&scop label-attr-db "Привязка к БД"
&scop tooltip-attr-db "С клиентом работают в текущей БД"
&scop user-can-edit-attr-db  true
&scop output-display-attr-db  true
&scop other-attr-db '':u
&scop news-attr-db false
&scop manual-edit-attr-db  1
&scop batch-edit-attr-db  1


/* Временной интервал возможности доставки */
&scop type-attr-delivery {&type-char}
&scop format-attr-delivery  "X(40)"
&scop label-attr-delivery   "Временной интервал возможности доставки"
&scop tooltip-attr-delivery  "Временной интервал возможности доставки"
&scop user-can-edit-attr-delivery  true
&scop output-display-attr-delivery  true
&scop other-attr-delivery '':u
&scop news-attr-delivery false
&scop manual-edit-attr-delivery  0
&scop batch-edit-attr-delivery  0


/* Временной интервал, запрещенный к доставке */
&scop type-attr-notdelivery {&type-char}
&scop format-attr-notdelivery  "X(40)"
&scop label-attr-notdelivery   "Временной интервал, запрещенный к доставке"
&scop tooltip-attr-notdelivery  "Временной интервал, запрещенный к доставке"
&scop user-can-edit-attr-notdelivery  true
&scop output-display-attr-notdelivery  true
&scop other-attr-notdelivery '':u
&scop news-attr-notdelivery false
&scop manual-edit-attr-notdelivery  0
&scop batch-edit-attr-notdelivery  0


/* Тип приобретения по умолчанию в приходной накладной  */
&scop bef-attr-purch-code             purch-code
&scop type-attr-purch-code            {&type-int}
&scop format-attr-purch-code          "9"
&scop label-attr-purch-code           "Тип приобретения"
&scop tooltip-attr-purch-code         "Тип приобретения"
&scop user-can-edit-attr-purch-code   true
&scop output-display-attr-purch-code  true
&scop other-attr-purch-code           '':u
&scop news-attr-purch-code            true
&scop manual-edit-attr-purch-code  0
&scop batch-edit-attr-purch-code  0

/* Торговля чужим товаром */
&scop bef-attr-als-gds             als-gds
&scop type-attr-als-gds            {&type-log}
&scop format-attr-als-gds          "yes/no"
&scop label-attr-als-gds           "Торговля чужим товаром"
&scop tooltip-attr-als-gds         "Торговля чужим товаром"
&scop user-can-edit-attr-als-gds   false
&scop output-display-attr-als-gds  true
&scop other-attr-als-gds           '':u
&scop news-attr-als-gds            true
&scop manual-edit-attr-als-gds  0
&scop batch-edit-attr-als-gds  0

/* чужая фирма */
&scop bef-attr-alien             alien
&scop type-attr-alien            {&type-log}
&scop format-attr-alien          "yes/no"
&scop label-attr-alien           "ЧУЖАЯ фирма/клиент"
&scop tooltip-attr-alien         "Фирма, товарный учет которой ведется в ДРУГОЙ СИСТЕМЕ TH или клиент, импортированный из ДРУГОЙ СИСТЕМЫ"
&scop user-can-edit-attr-alien   false
&scop output-display-attr-alien  true
&scop other-attr-alien           '':u
&scop news-attr-alien            true
&scop manual-edit-attr-alien  0
&scop batch-edit-attr-alien  0

/* КПП */
&scop bef-attr-kpp               kpp
&scop type-attr-kpp              {&type-char}
&scop format-attr-kpp            "X(20)"
&scop label-attr-kpp             "КПП"
&scop tooltip-attr-kpp           "Код причины постановки на учет"
&scop user-can-edit-attr-kpp     true
&scop output-display-attr-kpp    true
&scop other-attr-kpp             '':u
&scop news-attr-kpp              true
&scop manual-edit-attr-kpp       0
&scop batch-edit-attr-kpp        0

/* ЕНВД */
&scop bef-attr-envd              envd
&scop type-attr-envd             {&type-log}
&scop format-attr-envd           "yes/no"
&scop label-attr-envd            "ЕНВД"
&scop tooltip-attr-envd          "Единый налог на вмененный доход"
&scop user-can-edit-attr-envd    false
&scop output-display-attr-envd   true
&scop other-attr-envd            '':u
&scop news-attr-envd             true
&scop manual-edit-attr-envd  0
&scop batch-edit-attr-envd  0

/* Аптека */
&scop bef-attr-pharm              pharm
&scop type-attr-pharm             {&type-log}
&scop format-attr-pharm           "yes/no"
&scop label-attr-pharm            "Аптека"
&scop tooltip-attr-pharm          "Объект работает как АПТЕКА"
&scop user-can-edit-attr-pharm    false
&scop output-display-attr-pharm   true
&scop other-attr-pharm            '':u
&scop news-attr-pharm             true
&scop manual-edit-attr-pharm  0
&scop batch-edit-attr-pharm  0

/* Расписание (интервал повторения) для алармов на воду и уровень АТД */
&scop bef-attr-atd-alarm-schedule               atd-alarm-schedule
&scop type-attr-atd-alarm-schedule              {&type-char}
&scop format-attr-atd-alarm-schedule            "X(40)"
&scop label-attr-atd-alarm-schedule             "Расписание алармов АТД"
&scop tooltip-attr-atd-alarm-schedule           "Интервал повторения для алармов на воду и уровень АТД"
&scop user-can-edit-attr-atd-alarm-schedule     true
&scop output-display-attr-atd-alarm-schedule    true
&scop other-attr-atd-alarm-schedule             '':u
&scop news-attr-atd-alarm-schedule              true
&scop manual-edit-attr-atd-alarm-schedule       0
&scop batch-edit-attr-atd-alarm-schedule        0

/* дата время обновления актуальности информации - при импорте с другой системы */
&scop bef-attr-cli-upd-date-time              upd-date-time
&scop type-attr-cli-upd-date-time             {&type-char}
&scop format-attr-cli-upd-date-time           "X(19)"
&scop label-attr-cli-upd-date-time            "Актуальность информации"
&scop tooltip-attr-cli-upd-date-time          "Дата и время актуальности информации - при импорте из другой системы"
&scop user-can-edit-attr-cli-upd-date-time    false
&scop output-display-attr-cli-upd-date-time   true
&scop other-attr-cli-upd-date-time            '':u
&scop news-attr-cli-upd-date-time             true
&scop manual-edit-attr-cli-upd-date-time  0
&scop batch-edit-attr-cli-upd-date-time  0


/* код фирмы для печати накладных - если для объекта задан параметр outhold */
&scop type-attr-holdfirm-code            {&type-int}
&scop format-attr-holdfirm-code          ">>>>>9"
&scop label-attr-holdfirm-code           "Код фирмы для печати накладных"
&scop tooltip-attr-holdfirm-code         "Код фирмы для печати накладных - если для объекта задан параметр outhold"
&scop user-can-edit-attr-holdfirm-code   false
&scop output-display-attr-holdfirm-code  false
&scop other-attr-holdfirm-code           '':U
&scop news-attr-holdfirm-code            true
&scop manual-edit-attr-holdfirm-code  0
&scop batch-edit-attr-holdfirm-code  0



/*Неправильные архивы arh-trn-doc-contract по объекту*/
&scop type-attr-arh-trn-doc-contract {&type-log}
&scop format-attr-arh-trn-doc-contract "+/"
&scop label-attr-arh-trn-doc-contract "Неправильные архивы arh-trn-doc-contract по объекту"
&scop tooltip-attr-arh-trn-doc-contract "Неправильные архивы arh-trn-doc-contract по объекту"
&scop user-can-edit-attr-arh-trn-doc-contract false
&scop output-display-attr-arh-trn-doc-contract true
&scop other-attr-arh-trn-doc-contract '':U
&scop news-attr-arh-trn-doc-contract false
&scop manual-edit-attr-trn-doc-contract  0
&scop batch-edit-attr-trn-doc-contract  0


/* Свидетельство о постановке на учет по НДС серия{&delim-par}Номер{&delim-par}Дата */
&scop type-attr-vat-register {&type-char}
&scop format-attr-vat-register  "X(24)"
&scop label-attr-vat-register   "Свидетельство о постановке на учет по НДС(Каз.)"
&scop tooltip-attr-vat-register  "Свидетельство о постановке на учет по НДС(Каз.)"
&scop user-can-edit-attr-vat-register  true
&scop output-display-attr-vat-register  true
&scop other-attr-vat-register 'spr=clntattr-vat-register':u
&scop news-attr-vat-register yes
&scop manual-edit-attr-vat-register  1
&scop batch-edit-attr-vat-register  1



/* Дата последней выгруженной смены для объекта */
&scop type-attr-bge-incr-last-shift-date {&type-char}
&scop format-attr-bge-incr-last-shift-date "X(13)"
&scop label-attr-bge-incr-last-shift-date "Дата последней выгруженной смены"
&scop tooltip-attr-bge-incr-last-shift-date "Дата последней выгруженной смены"
&scop user-can-edit-attr-bge-incr-last-shift-date false
&scop output-display-attr-bge-incr-last-shift-date true
&scop other-attr-bge-incr-last-shift-date '':u
&scop news-attr-bge-incr-last-shift-date false
&scop manual-edit-attr-bge-incr-last-shift-date  0
&scop batch-edit-attr-bge-incr-last-shift-date  0


/* Номер последней выгруженной смены для объекта */
&scop type-attr-bge-incr-last-shift-num {&type-char}
&scop format-attr-bge-incr-last-shift-num "X(13)"
&scop label-attr-bge-incr-last-shift-num "Порядок последней выгруженной смены"
&scop tooltip-attr-bge-incr-last-shift-num "Порядок последней выгруженной смены"
&scop user-can-edit-attr-bge-incr-last-shift-num false
&scop output-display-attr-bge-incr-last-shift-num true
&scop other-attr-bge-incr-last-shift-num '':u
&scop news-attr-bge-incr-last-shift-num false
&scop manual-edit-attr-bge-incr-last-shift-num  0
&scop batch-edit-attr-bge-incr-last-shift-num  0


/* Выгружается ли смена в данный момент */
&scop type-attr-bge-incr-cur {&type-log}
&scop format-attr-bge-incr-cur "+/"
&scop label-attr-bge-incr-cur "Выгружается ли смена в данный момент"
&scop tooltip-attr-bge-incr-cur "Выгружается ли смена в данный момент"
&scop user-can-edit-attr-bge-incr-cur  false
&scop output-display-attr-bge-incr-cur  false
&scop other-attr-bge-incr-cur '':u
&scop news-attr-bge-incr-cur false
&scop manual-edit-attr-bge-incr-cur  0
&scop batch-edit-attr-bge-incr-cur  0


/* Дата и номер последней выгруженной смены в SAP ECC 6.0 ОАО "Сургутнефтегаз" */
&scop type-attr-bge-sap-sng-last-shift {&type-char}
&scop format-attr-bge-sap-sng-last-shift "X(13)"
&scop label-attr-bge-sap-sng-last-shift "Дата последней выгруженной смены"
&scop tooltip-attr-bge-sap-sng-last-shift "Дата последней выгруженной смены"
&scop user-can-edit-attr-bge-sap-sng-last-shift false
&scop output-display-attr-bge-sap-sng-last-shift true
&scop other-attr-bge-sap-sng-last-shift '':u
&scop news-attr-bge-sap-sng-last-shift false
&scop manual-edit-attr-bge-sap-sng-last-shift 0
&scop batch-edit-attr-bge-sap-sng-last-shift 0

/* Дата и номер последней выгруженной смены  в формате Малины */
&scop type-attr-bge-exp-malina-last-shift {&type-char}
&scop format-attr-bge-exp-malina-last-shift "X(13)"
&scop label-attr-bge-exp-malina-last-shift "Дата и номер последней выгруженной смены в формате Малины"
&scop tooltip-attr-bge-exp-malina-last-shift "Дата и номер последней выгруженной смены в формате Малины"
&scop user-can-edit-attr-bge-exp-malina-last-shift false
&scop output-display-attr-bge-exp-malina-last-shift true
&scop other-attr-bge-exp-malina-last-shift '':u
&scop news-attr-bge-exp-malina-last-shift false
&scop manual-edit-attr-bge-exp-malina-last-shift 0
&scop batch-edit-attr-bge-exp-malina-last-shift 0

/* Дата и номер последней выгруженной смены в систему АТД */
&scop type-attr-bge-exp-last-atd {&type-char}
&scop format-attr-bge-exp-last-atd "X(20)"
&scop label-attr-bge-exp-last-atd "Дата и номер последней выгруженной смены в систему АТД "
&scop tooltip-attr-bge-exp-last-atd "Дата и номер последней выгруженной смены в систему АТД "
&scop user-can-edit-attr-bge-exp-last-atd false
&scop output-display-attr-bge-exp-last-atd true
&scop other-attr-bge-exp-last-atd '':u
&scop news-attr-bge-exp-last-atd false
&scop manual-edit-attr-bge-exp-last-atd 0
&scop batch-edit-attr-bge-exp-last-atd 0

/* Дата ЕГРИП */
&scop type-attr-egrip-date {&type-char}
&scop format-attr-egrip-date "X(13)"
&scop label-attr-egrip-date "Дата ЕГРИП"
&scop tooltip-attr-egrip-date "Дата ЕГРИП"
&scop user-can-edit-attr-egrip-date true
&scop output-display-attr-egrip-date true
&scop other-attr-egrip-date '':u
&scop news-attr-egrip-date true
&scop manual-edit-attr-egrip-date  0
&scop batch-edit-attr-egrip-date  0

/* Номер ЕГРИП */
&scop type-attr-egrip-num {&type-char}
&scop format-attr-egrip-num "X(15)"
&scop label-attr-egrip-num "Номер ЕГРИП"
&scop tooltip-attr-egrip-num "Номер ЕГРИП"
&scop user-can-edit-attr-egrip-num true
&scop output-display-attr-egrip-num true
&scop other-attr-egrip-num '':u
&scop news-attr-egrip-num true
&scop manual-edit-attr-egrip-num  0
&scop batch-edit-attr-egrip-num  0

/* Код оплаты для производства */
&scop type-attr-fbr-pay-code            {&type-int}
&scop format-attr-fbr-pay-code          ">>>>>9"
&scop label-attr-fbr-pay-code           "Код оплаты для производства"
&scop tooltip-attr-fbr-pay-code         "Код оплаты для производства"
&scop user-can-edit-attr-fbr-pay-code   false
&scop output-display-attr-fbr-pay-code  false
&scop other-attr-fbr-pay-code           '':U
&scop news-attr-fbr-pay-code            true
&scop manual-edit-attr-fbr-pay-code  0
&scop batch-edit-attr-fbr-pay-code  0


/* Грузоотправитель */
&scop type-attr-cargo-from {&type-char}
&scop format-attr-cargo-from  "X(256)"
&scop label-attr-cargo-from   "Грузоотправитель"
&scop tooltip-attr-cargo-from   "Грузоотправитель"
&scop user-can-edit-attr-cargo-from  true
&scop output-display-attr-cargo-from  true
&scop other-attr-cargo-from  '':u
&scop news-attr-cargo-from false
&scop manual-edit-attr-cargo-from  1
&scop batch-edit-attr-cargo-from  1


/* Грузополучатель */
&scop type-attr-cargo-to {&type-char}
&scop format-attr-cargo-to  "X(256)"
&scop label-attr-cargo-to   "Грузополучатель"
&scop tooltip-attr-cargo-to   "Грузополучатель"
&scop user-can-edit-attr-cargo-to  true
&scop output-display-attr-cargo-to  true
&scop other-attr-cargo-to  '':u
&scop news-attr-cargo-to false
&scop manual-edit-attr-cargo-to 1
&scop batch-edit-attr-cargo-to  1


/* Атрибут клиента - местный */
&scop type-attr-cli-local {&type-log}
&scop format-attr-cli-local "+/"
&scop label-attr-cli-local "Местный клиент"
&scop tooltip-attr-cli-local "Местный клиент"
&scop user-can-edit-attr-cli-local  true
&scop output-display-attr-cli-local  true
&scop other-attr-cli-local '':u
&scop news-attr-cli-local false
&scop manual-edit-attr-cli-local  1
&scop batch-edit-attr-cli-local  1


/* Атрибут клиента - производитель алкогольной продукции */
&scop type-attr-cli-alc-producer {&type-log}
&scop format-attr-cli-alc-producer "+/"
&scop label-attr-cli-alc-producer "Производитель алкогольной продукции"
&scop tooltip-attr-cli-alc-producer "Производитель алкогольной продукции"
&scop user-can-edit-attr-cli-alc-producer  true
&scop output-display-attr-cli-alc-producer  true
&scop other-attr-cli-alc-producer '':u
&scop news-attr-cli-alc-producer true
&scop manual-edit-attr-cli-alc-producer  1
&scop batch-edit-attr-cli-alc-producer  1


/* код региона */
&scop type-attr-region-code {&type-int}
&scop format-attr-region-code ">9"
&scop label-attr-region-code "Код региона"
&scop tooltip-attr-region-code "Код региона"
&scop user-can-edit-attr-region-code  true
&scop output-display-attr-region-code  true
&scop other-attr-region-code '':u
&scop news-attr-region-code false
&scop manual-edit-attr-region-code  1
&scop batch-edit-attr-region-code  1


/* импортный производитель */
&scop type-attr-foreign-producer {&type-log}
&scop format-attr-foreign-producer "+/"
&scop label-attr-foreign-producer "Импортный производитель"
&scop tooltip-attr-foreign-producer "Импортный производитель"
&scop user-can-edit-attr-foreign-producer  true
&scop output-display-attr-foreign-producer  true
&scop other-attr-foreign-producer '':u
&scop news-attr-foreign-producer true
&scop manual-edit-attr-foreign-producer  1
&scop batch-edit-attr-foreign-producer  1

/* Контрагент - держатель основного счета - если расчетные счета контрагентов различаются только номером ЛИЦЕВОГО СЧЕТА*/
&scop type-attr-main-accholder {&type-char}
&scop format-attr-main-accholder  "X(12)"
&scop label-attr-main-accholder   "Контрагент - держатель основного счета"
&scop tooltip-attr-main-accholder  "Контрагент - держатель основного счета"
&scop user-can-edit-attr-main-accholder  true
&scop output-display-attr-main-accholder  true
&scop other-attr-main-accholder 'spr=clntattr-main-accholder':u
&scop news-attr-main-accholder yes
&scop manual-edit-attr-main-accholder  1
&scop batch-edit-attr-main-accholder  1

/* Обязателен авторасчет заказов ОП.Запрет на корректировку автоматич. рассчитанных заказов  */
&scop type-attr-not-corr-op  {&type-log}
&scop format-attr-not-corr-op  "+/"
&scop label-attr-not-corr-op  "Обязателен авторасчет заказов ОП.Запрет на корректировку автоматич. рассчитанных заказов"
&scop tooltip-attr-not-corr-op  "Обязателен авторасчет заказов ОП.Запрет на корректировку автоматич. рассчитанных заказов ОП"
&scop user-can-edit-attr-not-corr-op   true
&scop output-display-attr-not-corr-op  true
&scop other-attr-not-corr-op  '':u
&scop news-attr-not-corr-op  true
&scop manual-edit-attr-not-corr-op   1
&scop batch-edit-attr-not-corr-op   1

/* Атрибут клиента - запрет на ручный доуцменты */
&scop type-attr-veto-man-doc {&type-char}
&scop format-attr-veto-man-doc "X(255)"
&scop label-attr-veto-man-doc "Запрет на созд. оператором док-тов для контрагента"
&scop tooltip-attr-veto-man-doc "Запрет на созд. оператором док-тов для данного контрагента"
&scop user-can-edit-attr-veto-man-doc  true
&scop output-display-attr-veto-man-doc  true
&scop other-attr-veto-man-doc 'spr=clntattr-veto-man-doc':u
&scop news-attr-veto-man-doc true
&scop manual-edit-attr-veto-man-doc  1
&scop batch-edit-attr-veto-man-doc  1

/* Атрибут клиента - реквизиты для алкогольной декларации */
&scop type-attr-requisite-alc-decl {&type-char}
&scop format-attr-requisite-alc-decl "X(255)"
&scop label-attr-requisite-alc-decl "Реквизиты для алкогольной декларации"
&scop tooltip-attr-requisite-alc-decl "Реквизиты для алкогольной декларации"
&scop user-can-edit-attr-requisite-alc-decl  true
&scop output-display-attr-requisite-alc-decl  true
&scop other-attr-requisite-alc-decl 'spr=clntattr-requisite-alc-decl':u
&scop news-attr-requisite-alc-decl true
&scop manual-edit-attr-requisite-alc-decl  1
&scop batch-edit-attr-requisite-alc-decl  1

/* Атрибут клиента - код подразделения */
&scop type-attr-division-code {&type-int}
&scop format-attr-division-code ">>>>9"
&scop label-attr-division-code "Код подразделения"
&scop tooltip-attr-division-code "Код подразделени "
&scop user-can-edit-attr-division-code  true
&scop output-display-attr-division-code  true
&scop other-attr-division-code '':u
&scop news-attr-division-code true
&scop manual-edit-attr-division-code  1
&scop batch-edit-attr-division-code  1

/* Атрибут клиента - Поставщик НП   */
&scop type-attr-supp-np  {&type-log}
&scop format-attr-supp-np  "+/"
&scop label-attr-supp-np  "Поставщик НП"
&scop tooltip-attr-supp-np  "Поставщик НП"
&scop user-can-edit-attr-supp-np   true
&scop output-display-attr-supp-np  true
&scop other-attr-supp-np  '':u
&scop news-attr-supp-np  true
&scop manual-edit-attr-supp-np   1
&scop batch-edit-attr-supp-np   1

/* Атрибут клиента - Собственный поставщик   */
&scop type-attr-own-supp  {&type-log}
&scop format-attr-own-supp  "+/"
&scop label-attr-own-supp  "Собственный поставщик"
&scop tooltip-attr-own-supp  "Собственный поставщик"
&scop user-can-edit-attr-own-supp   true
&scop output-display-attr-own-supp  true
&scop other-attr-own-supp  '':u
&scop news-attr-own-supp  true
&scop manual-edit-attr-own-supp   1
&scop batch-edit-attr-own-supp   1

/* Атрибут клиента - Поставщик СУГ   */
&scop type-attr-supp-lgas  {&type-log}
&scop format-attr-supp-lgas  "+/"
&scop label-attr-supp-lgas  "Поставщик СУГ"
&scop tooltip-attr-supp-lgas  "Поставщик СУГ"
&scop user-can-edit-attr-supp-lgas   true
&scop output-display-attr-supp-lgas  true
&scop other-attr-supp-lgas  '':u
&scop news-attr-supp-lgas  true
&scop manual-edit-attr-supp-lgas   1
&scop batch-edit-attr-supp-lgas   1

/* Атрибут клиента - является нефтебазой/ГНС для:*/
&scop type-attr-tank-farm-for {&type-char}
&scop format-attr-tank-farm-for "X(255)"
&scop label-attr-tank-farm-for "Является нефтебазой/ГНС для:"
&scop tooltip-attr-tank-farm-for "Является нефтебазой/ГНС для:"
&scop user-can-edit-attr-tank-farm-for  true
&scop output-display-attr-tank-farm-for  true
&scop other-attr-tank-farm-for 'spr=clntattr-tank-farm-for':u
&scop news-attr-tank-farm-for true
&scop manual-edit-attr-tank-farm-for  1
&scop batch-edit-attr-tank-farm-for  1

/* Атрибут клиента - Нефтеперерабатывающий завод (НПЗ)   */
&scop type-attr-NPZ  {&type-log}
&scop format-attr-NPZ  "+/"
&scop label-attr-NPZ  "Нефтеперерабатывающий завод"
&scop tooltip-attr-NPZ  "Нефтеперерабатывающий завод"
&scop user-can-edit-attr-NPZ   true
&scop output-display-attr-NPZ  true
&scop other-attr-NPZ  '':u
&scop news-attr-NPZ  true
&scop manual-edit-attr-NPZ   1
&scop batch-edit-attr-NPZ   1

/* Атрибут клиента - код КСК */
&scop type-attr-code-KSK {&type-char}
&scop format-attr-code-KSK  "X(256)"
&scop label-attr-code-KSK   "Код КСК"
&scop tooltip-attr-code-KSK   "Код КСК"
&scop user-can-edit-attr-code-KSK  true
&scop output-display-attr-code-KSK  true
&scop other-attr-code-KSK  '':u
&scop news-attr-code-KSK false
&scop manual-edit-attr-code-KSK  1
&scop batch-edit-attr-code-KSK  1

/*  Атрибут клиента - код АИС */
&scop type-attr-code-AIS {&type-char}
&scop format-attr-code-AIS  "X(256)"
&scop label-attr-code-AIS   "Код АИС"
&scop tooltip-attr-code-AIS   "Код АИС"
&scop user-can-edit-attr-code-AIS  true
&scop output-display-attr-code-AIS  true
&scop other-attr-code-AIS  '':u
&scop news-attr-code-AIS false
&scop manual-edit-attr-code-AIS  1
&scop batch-edit-attr-code-AIS  1

/* Атрибут клиента - являестся перевозчиком для:*/
&scop type-attr-auto-tank-for {&type-char}
&scop format-attr-auto-tank-for "X(255)"
&scop label-attr-auto-tank-for "Является перевозчиком для:"
&scop tooltip-attr-auto-tank-for "Является перевозчиком для:"
&scop user-can-edit-attr-auto-tank-for  true
&scop output-display-attr-auto-tank-for  true
&scop other-attr-auto-tank-for 'spr=clntattr-auto-tank-for':u
&scop news-attr-auto-tank-for true
&scop manual-edit-attr-auto-tank-for  1
&scop batch-edit-attr-auto-tank-for  1

/* Атрибут клиента - являестся поставщиком для:*/
&scop type-attr-owner-code {&type-char}
&scop format-attr-owner-code "X(255)"
&scop label-attr-owner-code "Код ПНПО-владельца"
&scop tooltip-attr-owner-code "Код ПНПО-владельца"
&scop user-can-edit-attr-owner-code  true
&scop output-display-attr-owner-code  true
&scop other-attr-owner-code 'spr=clntattr-owner-code':u
&scop news-attr-owner-code true
&scop manual-edit-attr-owner-code  1
&scop batch-edit-attr-owner-code  1

/* Атрибут клиента - Список юр.лиц, платежами которых можно закрывать ФО:*/
&scop type-attr-cli-for-close-fo {&type-char}
&scop format-attr-cli-for-close-fo "X(255)"
&scop label-attr-cli-for-close-fo "Список юр.лиц, платежами которых можно закрывать ФО:"
&scop tooltip-attr-cli-for-close-fo "Список юр.лиц, платежами которых можно закрывать ФО:"
&scop user-can-edit-attr-cli-for-close-fo  true
&scop output-display-attr-cli-for-close-fo  true
&scop other-attr-cli-for-close-fo 'spr=clntattr-cli-for-close-fo':u
&scop news-attr-cli-for-close-fo true
&scop manual-edit-attr-cli-for-close-fo  1
&scop batch-edit-attr-cli-for-close-fo  1

/* Атрибут клиента - Климатическая группа:*/
&scop type-attr-cli-clim-grp {&type-char}
&scop format-attr-cli-clim-grp "X(21)"
&scop label-attr-cli-clim-grp "Климатическая группа:"
&scop tooltip-attr-cli-clim-grp "Климатическая группа:"
&scop user-can-edit-attr-cli-clim-grp  true
&scop output-display-attr-cli-clim-grp  true
&scop other-attr-cli-clim-grp 'spr=clntattr-cli-clim-grp':u
&scop news-attr-cli-clim-grp true
&scop manual-edit-attr-cli-clim-grp  1
&scop batch-edit-attr-cli-clim-grp  1

/* Атрибут клиента - Выведен из эксплуатации:*/
&scop type-attr-cli-decommissioned {&type-log}
&scop format-attr-cli-decommissioned "+/"
&scop label-attr-cli-decommissioned "Выведен из эксплуатации"
&scop tooltip-attr-cli-decommissioned "Выведен из эксплуатации"
&scop user-can-edit-attr-cli-decommissioned  true
&scop output-display-attr-cli-decommissioned  true
&scop other-attr-cli-decommissioned '':u
&scop news-attr-cli-decommissioned true
&scop manual-edit-attr-cli-decommissioned  1
&scop batch-edit-attr-cli-decommissioned  1

/* Атрибут клиента - Последняя выгруженная для ИС ПМ дата:*/
&scop type-attr-exp-isPM-last-date {&type-date}
&scop format-attr-exp-isPM-last-date "99/99/9999"
&scop label-attr-exp-isPM-last-date "Последняя выгруженная для ИС ПМ дата"
&scop tooltip-attr-exp-isPM-last-date "Последняя выгруженная для ИС ПМ дата"
&scop user-can-edit-attr-exp-isPM-last-date true
&scop output-display-attr-exp-isPM-last-date true
&scop other-attr-exp-isPM-last-date '':u
&scop news-attr-exp-isPM-last-date false
&scop manual-edit-attr-exp-isPM-last-date 1
&scop batch-edit-attr-exp-isPM-last-date 1

/* сюда добавлять новые атрибуты клиентов */

/* ------------------------------------------------------------------- */
&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
when ~{&~{&attr-code~}~} then do: ~
  assign ~
  p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.




procedure clntattr-code :

  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-code :
      &scop attr-code attr-doc-start-date
      {&attr-temp-full-code}
      &scop attr-code attr-arh-detail-date
      {&attr-temp-full-code}
      &scop attr-code attr-arh-start-date
      {&attr-temp-full-code}
      &scop attr-code attr-ahsp-detail-date
      {&attr-temp-full-code}
      &scop attr-code attr-ahsp-start-date
      {&attr-temp-full-code}
      &scop attr-code attr-aht-detail-date
      {&attr-temp-full-code}
      &scop attr-code attr-aht-start-date
      {&attr-temp-full-code}
      &scop attr-code attr-arh-del
      {&attr-temp-full-code}
      &scop attr-code attr-ahsp-del
      {&attr-temp-full-code}
      &scop attr-code attr-aht-del
      {&attr-temp-full-code}
      &scop attr-code attr-arh-disable
      {&attr-temp-full-code}
      &scop attr-code attr-ahsp-disable
      {&attr-temp-full-code}
      &scop attr-code attr-aht-disable
      {&attr-temp-full-code}
      &scop attr-code attr-arh-calc
      {&attr-temp-full-code}
      &scop attr-code attr-ahsp-calc
      {&attr-temp-full-code}
      &scop attr-code attr-aht-calc
      {&attr-temp-full-code}
      &scop attr-code attr-arh-rest
      {&attr-temp-full-code}
      &scop attr-code attr-ahsp-rest
      {&attr-temp-full-code}
      &scop attr-code attr-aht-rest
      {&attr-temp-full-code}
      &scop attr-code attr-arh-recalc-date
      {&attr-temp-full-code}
      &scop attr-code attr-ahsp-recalc-date
      {&attr-temp-full-code}
      &scop attr-code attr-aht-recalc-date
      {&attr-temp-full-code}
      &scop attr-code attr-is-inkassator
      {&attr-temp-full-code}
      &scop attr-code attr-shftrep2
      {&attr-temp-full-code}
      &scop attr-code attr-db
      {&attr-temp-full-code}
      &scop attr-code attr-is-superviser
      {&attr-temp-full-code}
      &scop attr-code attr-purch-code
      {&attr-temp-full-code}
      &scop attr-code attr-als-gds
      {&attr-temp-full-code}
      &scop attr-code attr-alien
      {&attr-temp-full-code}
      &scop attr-code attr-envd
      {&attr-temp-full-code}
      &scop attr-code attr-kpp
      {&attr-temp-full-code}
      &scop attr-code attr-pharm
      {&attr-temp-full-code}
      &scop attr-code attr-cli-upd-date-time
      {&attr-temp-full-code}
      &scop attr-code attr-holdfirm-code
      {&attr-temp-full-code}
      &scop attr-code attr-arh-trn-doc-contract
      {&attr-temp-full-code}
      &scop attr-code attr-vat-register
      {&attr-temp-full-code}
      &scop attr-code attr-bge-incr-last-shift-date
      {&attr-temp-full-code}
      &scop attr-code attr-bge-incr-last-shift-num
      {&attr-temp-full-code}
      &scop attr-code attr-bge-incr-cur
      {&attr-temp-full-code}
      &scop attr-code attr-bge-sap-sng-last-shift
      {&attr-temp-full-code}
      &scop attr-code attr-bge-exp-last-atd
      {&attr-temp-full-code}
      &scop attr-code attr-bge-exp-malina-last-shift
      {&attr-temp-full-code}      
      &scop attr-code attr-egrip-date
      {&attr-temp-full-code}
      &scop attr-code attr-egrip-num
      {&attr-temp-full-code}
      &scop attr-code attr-fbr-pay-code
      {&attr-temp-full-code}
      &scop attr-code attr-cargo-from
      {&attr-temp-full-code}
      &scop attr-code attr-cargo-to
      {&attr-temp-full-code}
      &scop attr-code attr-cli-local
      {&attr-temp-full-code}
      &scop attr-code attr-cli-alc-producer
      {&attr-temp-full-code}
      &scop attr-code attr-region-code
      {&attr-temp-full-code}
      &scop attr-code attr-foreign-producer
      {&attr-temp-full-code}
      &scop attr-code attr-main-accholder
      {&attr-temp-full-code}
      &scop attr-code attr-not-corr-op
      {&attr-temp-full-code}
      &scop attr-code attr-veto-man-doc
      {&attr-temp-full-code}
      &scop attr-code attr-requisite-alc-decl
      {&attr-temp-full-code}
      &scop attr-code attr-division-code
      {&attr-temp-full-code}
      &scop attr-code attr-supp-np
      {&attr-temp-full-code}
      &scop attr-code attr-own-supp
      {&attr-temp-full-code}
      &scop attr-code attr-supp-lgas
      {&attr-temp-full-code}
      &scop attr-code attr-tank-farm-for
      {&attr-temp-full-code}
      &scop attr-code attr-NPZ
      {&attr-temp-full-code}
      &scop attr-code attr-code-KSK
      {&attr-temp-full-code}
      &scop attr-code attr-code-AIS
      {&attr-temp-full-code}
      &scop attr-code attr-auto-tank-for
      {&attr-temp-full-code}
      &scop attr-code attr-owner-code
      {&attr-temp-full-code}
      &scop attr-code attr-cli-for-close-fo
      {&attr-temp-full-code}
      &scop attr-code attr-cli-clim-grp
      {&attr-temp-full-code}
      &scop attr-code attr-cli-decommissioned
      {&attr-temp-full-code}
      &scop attr-code attr-atd-alarm-schedule
      {&attr-temp-full-code}
      &scop attr-code attr-exp-isPM-last-date
      {&attr-temp-full-code}

      /* сюда добавлять новые параметры атрибутов клиентов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure clntattr-tooltip :

  do
  on error undo, return error return-value
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-code :
      &scop attr-code attr-doc-start-date
      {&attr-temp-code}
      &scop attr-code attr-arh-detail-date
      {&attr-temp-code}
      &scop attr-code attr-arh-start-date
      {&attr-temp-code}
      &scop attr-code attr-ahsp-detail-date
      {&attr-temp-code}
      &scop attr-code attr-ahsp-start-date
      {&attr-temp-code}
      &scop attr-code attr-aht-detail-date
      {&attr-temp-code}
      &scop attr-code attr-aht-start-date
      {&attr-temp-code}
      &scop attr-code attr-arh-del
      {&attr-temp-code}
      &scop attr-code attr-ahsp-del
      {&attr-temp-code}
      &scop attr-code attr-aht-del
      {&attr-temp-code}
      &scop attr-code attr-arh-disable
      {&attr-temp-code}
      &scop attr-code attr-ahsp-disable
      {&attr-temp-code}
      &scop attr-code attr-aht-disable
      {&attr-temp-code}
      &scop attr-code attr-arh-calc
      {&attr-temp-code}
      &scop attr-code attr-ahsp-calc
      {&attr-temp-code}
      &scop attr-code attr-aht-calc
      {&attr-temp-code}
      &scop attr-code attr-arh-rest
      {&attr-temp-code}
      &scop attr-code attr-ahsp-rest
      {&attr-temp-code}
      &scop attr-code attr-aht-rest
      {&attr-temp-code}
      &scop attr-code attr-arh-recalc-date
      {&attr-temp-code}
      &scop attr-code attr-ahsp-recalc-date
      {&attr-temp-code}
      &scop attr-code attr-aht-recalc-date
      {&attr-temp-code}
      &scop attr-code attr-is-inkassator
      {&attr-temp-code}
      &scop attr-code attr-shftrep2
      {&attr-temp-code}
      &scop attr-code attr-db
      {&attr-temp-code}
      &scop attr-code attr-is-superviser
      {&attr-temp-code}
      &scop attr-code attr-purch-code
      {&attr-temp-code}
      &scop attr-code attr-als-gds
      {&attr-temp-code}
      &scop attr-code attr-alien
      {&attr-temp-code}
      &scop attr-code attr-envd
      {&attr-temp-code}
      &scop attr-code attr-kpp
      {&attr-temp-code}      
      &scop attr-code attr-pharm
      {&attr-temp-code}
      &scop attr-code attr-cli-upd-date-time
      {&attr-temp-code}
      &scop attr-code attr-holdfirm-code
      {&attr-temp-code}
      &scop attr-code attr-arh-trn-doc-contract
      {&attr-temp-code}
      &scop attr-code attr-vat-register
      {&attr-temp-code}
      &scop attr-code attr-bge-incr-last-shift-date
      {&attr-temp-code}
      &scop attr-code attr-bge-incr-last-shift-num
      {&attr-temp-code}
      &scop attr-code attr-bge-incr-cur
      {&attr-temp-code}
      &scop attr-code attr-bge-sap-sng-last-shift
      {&attr-temp-code}
      &scop attr-code attr-bge-exp-last-atd
      {&attr-temp-code}
      &scop attr-code attr-bge-exp-malina-last-shift
      {&attr-temp-code}      
      &scop attr-code attr-egrip-date
      {&attr-temp-code}
      &scop attr-code attr-egrip-num
      {&attr-temp-code}
      &scop attr-code attr-fbr-pay-code
      {&attr-temp-code}
      &scop attr-code attr-cargo-from
      {&attr-temp-code}
      &scop attr-code attr-cargo-to
      {&attr-temp-code}
      &scop attr-code attr-cli-local
      {&attr-temp-code}
      &scop attr-code attr-cli-alc-producer
      {&attr-temp-code}
      &scop attr-code attr-region-code
      {&attr-temp-code}
      &scop attr-code attr-foreign-producer
      {&attr-temp-code}
      &scop attr-code attr-main-accholder
      {&attr-temp-code}
      &scop attr-code attr-not-corr-op
      {&attr-temp-code}
      &scop attr-code attr-veto-man-doc
      {&attr-temp-code}
      &scop attr-code attr-requisite-alc-decl
      {&attr-temp-code}
      &scop attr-code attr-division-code
      {&attr-temp-code}
      &scop attr-code attr-supp-np
      {&attr-temp-code}
      &scop attr-code attr-own-supp
      {&attr-temp-code}
      &scop attr-code attr-supp-lgas
      {&attr-temp-code}
      &scop attr-code attr-tank-farm-for
      {&attr-temp-code}
      &scop attr-code attr-NPZ
      {&attr-temp-code}
      &scop attr-code attr-code-KSK
      {&attr-temp-code}
      &scop attr-code attr-code-AIS
      {&attr-temp-code}
      &scop attr-code attr-auto-tank-for
      {&attr-temp-code}
      &scop attr-code attr-owner-code
      {&attr-temp-code}
      &scop attr-code attr-cli-for-close-fo
      {&attr-temp-code}
      &scop attr-code attr-cli-clim-grp
      {&attr-temp-code}
      &scop attr-code attr-cli-decommissioned
      {&attr-temp-code}
      &scop attr-code attr-atd-alarm-schedule
      {&attr-temp-code}
      &scop attr-code attr-exp-isPM-last-date
      {&attr-temp-code}

      /* сюда добавлять новые параметры атрибутов клиентов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code ).
      end.
    end.
  end.

end procedure.

procedure clntattr-value :

  do
  on error undo, return error return-value
  :
    define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-value    like ub.clients-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_clients-attr for ub.clients-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run clntattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_clients-attr no-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error .
    if avail buf_clients-attr then do:
      assign
        p-value =  buf_clients-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.

procedure clntattr-write :

  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define input parameter p-value    like ub.clients-attr.attr-value no-undo .

    define buffer buf_clients-attr for ub.clients-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run clntattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_clients-attr exclusive-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error .
    if not available buf_clients-attr then do:
      create buf_clients-attr .
      assign
        buf_clients-attr.obj-type  = p-obj-type
        buf_clients-attr.obj-code  = p-obj-code
        buf_clients-attr.attr-code = p-code
      .
    end.
    assign
      buf_clients-attr.attr-value = p-value
    .
    release buf_clients-attr no-error.
    if error-status:error then do:
      return error substitute("Ошибка при сохранение атрибута &1 клиента &2&3: &4 &5"
                             , p-code
                             , p-obj-type
                             , p-obj-code
                             , error-status:get-message(1)
                             , return-value ).
    end.
  end.

end procedure.

procedure clntattr-exist :

  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_clients-attr for ub.clients-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run clntattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_clients-attr no-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error .
    if  available buf_clients-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure clntattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_clients-attr for ub.clients-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run clntattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_clients-attr exclusive-lock
      where buf_clients-attr.obj-type  = p-obj-type
        and buf_clients-attr.obj-code  = p-obj-code
        and buf_clients-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_clients-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_clients-attr no-error .
      if error-status:error then do:
        return error substitute("Ошибка при удалении атрибута &1 клиента &2&3: &4 &5"
                              , p-code
                              , p-obj-type
                              , p-obj-code
                              , error-status:get-message(1)
                              , return-value ).
      end.
      p-deleted = yes.
    end.
  end.

end procedure.

procedure clntattr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-code :
      &scop attr-code attr-doc-start-date
      {&attr-news-code}
      &scop attr-code attr-arh-detail-date
      {&attr-news-code}
      &scop attr-code attr-arh-start-date
      {&attr-news-code}
      &scop attr-code attr-ahsp-detail-date
      {&attr-news-code}
      &scop attr-code attr-ahsp-start-date
      {&attr-news-code}
      &scop attr-code attr-aht-detail-date
      {&attr-news-code}
      &scop attr-code attr-aht-start-date
      {&attr-news-code}
      &scop attr-code attr-arh-del
      {&attr-news-code}
      &scop attr-code attr-ahsp-del
      {&attr-news-code}
      &scop attr-code attr-aht-del
      {&attr-news-code}
      &scop attr-code attr-arh-disable
      {&attr-news-code}
      &scop attr-code attr-ahsp-disable
      {&attr-news-code}
      &scop attr-code attr-aht-disable
      {&attr-news-code}
      &scop attr-code attr-arh-calc
      {&attr-news-code}
      &scop attr-code attr-ahsp-calc
      {&attr-news-code}
      &scop attr-code attr-aht-calc
      {&attr-news-code}
      &scop attr-code attr-arh-rest
      {&attr-news-code}
      &scop attr-code attr-ahsp-rest
      {&attr-news-code}
      &scop attr-code attr-aht-rest
      {&attr-news-code}
      &scop attr-code attr-arh-recalc-date
      {&attr-news-code}
      &scop attr-code attr-ahsp-recalc-date
      {&attr-news-code}
      &scop attr-code attr-aht-recalc-date
      {&attr-news-code}
      &scop attr-code attr-is-inkassator
      {&attr-news-code}
      &scop attr-code attr-shftrep2
      {&attr-news-code}
      &scop attr-code attr-db
      {&attr-news-code}
      &scop attr-code attr-is-superviser
      {&attr-news-code}
      &scop attr-code attr-purch-code
      {&attr-news-code}
      &scop attr-code attr-als-gds
      {&attr-news-code}
      &scop attr-code attr-envd
      {&attr-news-code}
      &scop attr-code attr-kpp
      {&attr-news-code}
      &scop attr-code attr-pharm
      {&attr-news-code}
      &scop attr-code attr-cli-upd-date-time
      {&attr-news-code}
      &scop attr-code attr-holdfirm-code
      {&attr-news-code}
      &scop attr-code attr-cli-upd-date-time
      {&attr-news-code}
      &scop attr-code attr-arh-trn-doc-contract
      {&attr-news-code}
      &scop attr-code attr-vat-register
      {&attr-news-code}
      &scop attr-code attr-bge-incr-last-shift-date
      {&attr-news-code}
      &scop attr-code attr-bge-incr-last-shift-num
      {&attr-news-code}
      &scop attr-code attr-bge-incr-cur
      {&attr-news-code}
      &scop attr-code attr-bge-sap-sng-last-shift
      {&attr-news-code}
      &scop attr-code attr-bge-exp-last-atd
      {&attr-news-code}
      &scop attr-code attr-bge-exp-malina-last-shift
      {&attr-news-code} 
      &scop attr-code attr-egrip-date
      {&attr-news-code}
      &scop attr-code attr-egrip-num
      {&attr-news-code}
      &scop attr-code attr-fbr-pay-code
      {&attr-news-code}
      &scop attr-code attr-cargo-from
      {&attr-news-code}
      &scop attr-code attr-cargo-to
      {&attr-news-code}
      &scop attr-code attr-cli-local
      {&attr-news-code}
      &scop attr-code attr-cli-alc-producer
      {&attr-news-code}
      &scop attr-code attr-region-code
      {&attr-news-code}
      &scop attr-code attr-foreign-producer
      {&attr-news-code}
      &scop attr-code attr-main-accholder
      {&attr-news-code}
      &scop attr-code attr-not-corr-op
      {&attr-news-code}
      &scop attr-code attr-veto-man-doc
      {&attr-news-code}
      &scop attr-code attr-requisite-alc-decl
      {&attr-news-code}
      &scop attr-code attr-division-code
      {&attr-news-code}
      &scop attr-code attr-supp-np
      {&attr-news-code}
      &scop attr-code attr-own-supp
      {&attr-news-code}
      &scop attr-code attr-supp-lgas
      {&attr-news-code}
      &scop attr-code attr-tank-farm-for
      {&attr-news-code}
      &scop attr-code attr-NPZ
      {&attr-news-code}
      &scop attr-code attr-code-KSK
      {&attr-news-code}
      &scop attr-code attr-code-AIS
      {&attr-news-code}
      &scop attr-code attr-auto-tank-for
      {&attr-news-code}
      &scop attr-code attr-owner-code
      {&attr-news-code}
      &scop attr-code attr-cli-for-close-fo
      {&attr-news-code}
      &scop attr-code attr-cli-clim-grp
      {&attr-news-code}
      &scop attr-code attr-cli-decommissioned
      {&attr-news-code}
      &scop attr-code attr-atd-alarm-schedule
      {&attr-news-code}
      &scop attr-code attr-exp-isPM-last-date
      {&attr-news-code}

      /* сюда добавлять новые параметры атрибутов клиентов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure clntattr-copy-to :
do
  on error undo, return error
  :

  define input  parameter p-obj-type as character no-undo .  /*  obj-type */
  define input  parameter p-obj-code as integer   no-undo .  /*  obj-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define input  parameter p-bh       as handle no-undo .     /* буфер поле которого заполним */


  define buffer buf-clients-attr for ub.clients-attr.

  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define variable v-type           as character no-undo .


  run  clntattr-code  in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-clients-attr no-lock where
                buf-clients-attr.attr-code = p-code
            and buf-clients-attr.obj-type = p-obj-type
            and buf-clients-attr.obj-code = p-obj-code
             no-error .
   if not p-bh:available then do:
     p-bh:buffer-create().
   end.
   if avail buf-clients-attr then do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = buf-clients-attr.attr-value.
   end.
   else do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = if v-type = {&type-log} then "no":U else "".
   end.
end.
end procedure.


procedure clntattr-get-archive-attr :

  define output parameter p-archive-attr-list as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-archive-attr-list = {&attr-arh-detail-date}
          + {&comma-char} + {&attr-arh-start-date}
          + {&comma-char} + {&attr-ahsp-detail-date}
          + {&comma-char} + {&attr-ahsp-start-date}
          + {&comma-char} + {&attr-aht-detail-date}
          + {&comma-char} + {&attr-aht-start-date}
          + {&comma-char} + {&attr-arh-del}
          + {&comma-char} + {&attr-ahsp-del}
          + {&comma-char} + {&attr-aht-del}
          + {&comma-char} + {&attr-arh-disable}
          + {&comma-char} + {&attr-ahsp-disable}
          + {&comma-char} + {&attr-aht-disable}
          + {&comma-char} + {&attr-arh-calc}
          + {&comma-char} + {&attr-ahsp-calc}
          + {&comma-char} + {&attr-aht-calc}
          + {&comma-char} + {&attr-arh-rest}
          + {&comma-char} + {&attr-ahsp-rest}
          + {&comma-char} + {&attr-aht-rest}
          + {&comma-char} + {&attr-arh-recalc-date}
          + {&comma-char} + {&attr-ahsp-recalc-date}
          + {&comma-char} + {&attr-aht-recalc-date}
    .
  end.

end procedure. /* clntattr-get-archive-attr */

procedure clntattr-get-auto-author-attr :

  define output parameter p-archive-attr-list as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-archive-attr-list =  {&attr-bge-incr-last-shift-date}
          + {&comma-char} + {&attr-bge-incr-last-shift-num}
    .
  end.

end procedure. /* clntattr-get-auto-author-attr */


procedure clntattr-get-archive-by-type :

  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .

  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".

  do
  on error undo, return error return-value
  :
    case p-archive-type
    :
      when {&btpr-type-arh}
      then do:
        assign
          p-archive-attr-list = {&attr-arh-detail-date}
              + {&comma-char} + {&attr-arh-start-date}
              + {&comma-char} + {&attr-arh-del}
              + {&comma-char} + {&attr-arh-disable}
              + {&comma-char} + {&attr-arh-calc}
              + {&comma-char} + {&attr-arh-rest}
              + {&comma-char} + {&attr-arh-recalc-date}
        .
      end.
      when {&btpr-type-ahsp}
      then do:
        assign
          p-archive-attr-list = {&attr-ahsp-detail-date}
              + {&comma-char} + {&attr-ahsp-start-date}
              + {&comma-char} + {&attr-ahsp-del}
              + {&comma-char} + {&attr-ahsp-disable}
              + {&comma-char} + {&attr-ahsp-calc}
              + {&comma-char} + {&attr-ahsp-rest}
              + {&comma-char} + {&attr-ahsp-recalc-date}
        .
      end.
      when {&btpr-type-aht}
      then do:
        assign
          p-archive-attr-list = {&attr-aht-detail-date}
              + {&comma-char} + {&attr-aht-start-date}
              + {&comma-char} + {&attr-aht-del}
              + {&comma-char} + {&attr-aht-disable}
              + {&comma-char} + {&attr-aht-calc}
              + {&comma-char} + {&attr-aht-rest}
              + {&comma-char} + {&attr-aht-recalc-date}
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании входных параметров" skip
          "Неизвестное значение параметра p-archive-type" skip
          "p-archive-type" p-archive-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case.
  end.

end procedure. /* clntattr-get-archive-attr */


procedure clntattr-requisite-alc-decl :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-value = p-value
    .
    if  p-obj-type <> {&cmp}
    and p-obj-type <> {&prs}
    and p-obj-type <> {&shop}
    and p-obj-type <> {&stock}
    then do :
      message
        substitute("Нельзя установить данный атрибут для клиента с типом &1", p-obj-type)
        view-as alert-box error .
        undo, return error .
    end.
    run ref/requis-alc.w
      ( input p-obj-type
       ,input p-obj-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.

end procedure. /* clntattr-requisite-alc-decl */


procedure clntattr-tank-farm-for :

  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-code = "tank-farm-for"
      v-value = p-value
    .
    run str/clisel1.p
       (input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.  /* clntattr-tank-farm-for */

procedure clntattr-auto-tank-for :

  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-code = "auto-tank-for"
      v-value = p-value
    .
    run str/clisel1.p
      ( input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.  /* clntattr-auto-tank-for */

procedure clntattr-owner-code :

  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-code = "owner-code"
      v-value = p-value
    .
    run str/clisel1.p
      ( input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if num-entries(v-value) > 1
    then do :
      message "Выбрать можно только одного контрагента!" view-as alert-box .
      return error .
    end .
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.  /* clntattr-owner-code */

procedure clntattr-cli-for-close-fo :

  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-code = "cli-for-close-fo"
      v-value = p-value
    .
    run str/clisel1.p
      ( input parparentproc
       ,input p-obj-type
       ,input p-obj-code
       ,input v-code
       ,input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.
end procedure.  /* clntattr-auto-tank-for */


procedure clntattr-cli-clim-grp :
  define input parameter parparentproc as handle no-undo .
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-code  as character no-undo.
  define variable v-value as character no-undo .

  define variable v-dlg as class ibs.th.ref.dclimgrp no-undo .
  define variable v-err-msg as character no-undo .  

  do on error undo, throw :
    v-dlg = new ibs.th.ref.dclimgrp().
    if num-entries (p-value) = 3 then do :
      assign
      v-dlg:climGrp     = entry(1, p-value)
      v-dlg:beginSummer = entry(2, p-value)
      v-dlg:beginWinter = entry(3, p-value)
      .
    end .
    v-dlg:ShowModalDialog().
    if v-dlg:DialogResult = System.Windows.Forms.DialogResult:Ok then do:
      assign
        p-value  = substitute("&1,&2,&3", v-dlg:climGrp, v-dlg:beginSummer, v-dlg:beginWinter)
        p-setted = yes
      .
    end .
  
    v-err-msg = "" .  
    catch exAppErrors as class Progress.Lang.AppError :
      v-err-msg = exAppErrors:ReturnValue .
      if v-err-msg > "" then . else do :
        v-err-msg = exAppErrors:GetMessage(1) .
        if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
      end .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      v-err-msg = exProErrors:GetMessage(1) . 
      if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    end catch .
    finally :
      if valid-object (v-dlg) then delete object v-dlg .
      if v-err-msg <> "" then undo, throw new Progress.Lang.AppError(
        substitute("&1 {&FILE-NAME} &2", v-err-msg, "clntattr-cli-clim-grp")
      ) .
    end finally .
  end.
end procedure.  /* clntattr-cli-clim-grp */


procedure clntattr-vat-register :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
      v-value = p-value
    .
    if  p-obj-type <> {&cmp}
    and p-obj-type <> {&prs}
    then do:
      message
        substitute("Нельзя установить данный атрибут для клиента с типом &1", p-obj-type)
        view-as alert-box error .
    end.
    run ref/vatrg.w
      (input-output v-value
      ).
    if v-value <> p-value
    then do:
      assign
        p-value  = v-value
        p-setted = yes
      .
    end.
  end.

end procedure. /* clntattr-vat-register */

procedure clntattr-main-accholder :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-holder-obj-type as character no-undo .
define variable v-holder-obj-code as integer no-undo .

  do
  on error undo, return error
  :
      v-value = p-value.
      if p-obj-type <> {&cmp}
      and p-obj-type <> {&prs} then do:
        message
        substitute("Нельзя установить данный атрибут для клиента с типом &1", p-obj-type)
        view-as alert-box error .
        undo, return error .
      end.
      if p-value <> '':U then do:
        assign
        v-holder-obj-type = substring(p-value, 1, 3)
        v-holder-obj-code = integer(substring(p-value, 4))
        no-error.
        if error-status:error then do:
          assign
          v-holder-obj-type = '':U
          v-holder-obj-code = 0
          .
        end.
      end.
      run str/clisel.p ( input parparentproc
                    ,input-output v-holder-obj-type
                    ,input-output v-holder-obj-code) no-error.
      if not error-status:error then do:
        if not (v-holder-obj-type = {&cmp}
               or
               v-holder-obj-type = {&prs}) then do:
          message
          substitute("Нельзя назначить держателем основного счета клиента с типом &1", v-holder-obj-type)
          view-as alert-box error .
          undo, return error .
        end.
        assign
        v-value = v-holder-obj-type + "," + string(v-holder-obj-code)
        .
        if v-value <> p-value then do:
          p-value = v-value.
          p-setted = yes.
        end.
     end.
  end.

end procedure. /* clntattr-main-accholder */

procedure clntattr-veto-man-doc :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .

  do
  on error undo, return error
  :
      v-value = p-value.
      if p-value = '':U then do:
        p-value = "ALL".
        p-setted = yes.
        return.
      end.
      else do:
        message
        "Данный атрибут может либо отсутствовать," skip
        "либо принимать значение ALL"
        view-as alert-box warning.
      end.
  end.

end procedure. /* clntattr-veto-man-doc */



procedure clntattr-manual-edit :

  do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-shftrep2
      {&attr-manual-edit-code}
      &scop attr-code attr-is-inkassator
      {&attr-manual-edit-code}
      &scop attr-code attr-is-superviser
      {&attr-manual-edit-code}
      &scop attr-code attr-db
      {&attr-manual-edit-code}
      &scop attr-code attr-vat-register
      {&attr-manual-edit-code}
      &scop attr-code attr-cargo-from
      {&attr-manual-edit-code}
      &scop attr-code attr-cargo-to
      {&attr-manual-edit-code}
      &scop attr-code attr-cli-local
      {&attr-manual-edit-code}
      &scop attr-code attr-cli-alc-producer
      {&attr-manual-edit-code}
      &scop attr-code attr-region-code
      {&attr-manual-edit-code}
      &scop attr-code attr-foreign-producer
      {&attr-manual-edit-code}
      &scop attr-code attr-main-accholder
      {&attr-manual-edit-code}
      &scop attr-code attr-not-corr-op
      {&attr-manual-edit-code}
      &scop attr-code attr-veto-man-doc
      {&attr-manual-edit-code}
      &scop attr-code attr-requisite-alc-decl
      {&attr-manual-edit-code}
      &scop attr-code attr-division-code
      {&attr-manual-edit-code}
      &scop attr-code attr-supp-np
      {&attr-manual-edit-code}
      &scop attr-code attr-own-supp
      {&attr-manual-edit-code}
      &scop attr-code attr-supp-lgas
      {&attr-manual-edit-code}
      &scop attr-code attr-tank-farm-for
      {&attr-manual-edit-code}
      &scop attr-code attr-NPZ
      {&attr-manual-edit-code}
      &scop attr-code attr-code-KSK
      {&attr-manual-edit-code}
      &scop attr-code attr-code-AIS
      {&attr-manual-edit-code}
      &scop attr-code attr-auto-tank-for
      {&attr-manual-edit-code}
      &scop attr-code attr-owner-code
      {&attr-manual-edit-code}
      &scop attr-code attr-cli-for-close-fo
      {&attr-manual-edit-code}
      &scop attr-code attr-cli-clim-grp
      {&attr-manual-edit-code}
      &scop attr-code attr-cli-decommissioned
      {&attr-manual-edit-code}
      &scop attr-code attr-atd-alarm-schedule
      {&attr-manual-edit-code}
      &scop attr-code attr-exp-isPM-last-date
      {&attr-manual-edit-code}

      /* сюда добавлять новые параметры атрибутов клиентов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code) .
      end.
    end.
  end.
end procedure.


procedure clntattr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-shftrep2
      {&attr-batch-edit-code}
      &scop attr-code attr-is-inkassator
      {&attr-batch-edit-code}
      &scop attr-code attr-is-superviser
      {&attr-batch-edit-code}
      &scop attr-code attr-db
      {&attr-batch-edit-code}
      &scop attr-code attr-vat-register
      {&attr-batch-edit-code}
      &scop attr-code attr-cargo-from
      {&attr-batch-edit-code}
      &scop attr-code attr-cargo-to
      {&attr-batch-edit-code}
      &scop attr-code attr-cli-local
      {&attr-batch-edit-code}
      &scop attr-code attr-cli-alc-producer
      {&attr-batch-edit-code}
      &scop attr-code attr-region-code
      {&attr-batch-edit-code}
      &scop attr-code attr-foreign-producer
      {&attr-batch-edit-code}
      &scop attr-code attr-main-accholder
      {&attr-batch-edit-code}
      &scop attr-code attr-not-corr-op
      {&attr-batch-edit-code}
      &scop attr-code attr-veto-man-doc
      {&attr-batch-edit-code}
      &scop attr-code attr-requisite-alc-decl
      {&attr-batch-edit-code}
      &scop attr-code attr-division-code
      {&attr-batch-edit-code}
      &scop attr-code attr-supp-np
      {&attr-batch-edit-code}
      &scop attr-code attr-own-supp
      {&attr-batch-edit-code}
      &scop attr-code attr-supp-lgas
      {&attr-batch-edit-code}
      &scop attr-code attr-tank-farm-for
      {&attr-batch-edit-code}
      &scop attr-code attr-NPZ
      {&attr-batch-edit-code}
      &scop attr-code attr-code-KSK
      {&attr-batch-edit-code}
      &scop attr-code attr-code-AIS
      {&attr-batch-edit-code}
      &scop attr-code attr-auto-tank-for
      {&attr-batch-edit-code}
      &scop attr-code attr-owner-code
      {&attr-batch-edit-code}
      &scop attr-code attr-cli-for-close-fo
      {&attr-batch-edit-code}
      &scop attr-code attr-cli-clim-grp
      {&attr-batch-edit-code}
      &scop attr-code attr-cli-decommissioned
      {&attr-batch-edit-code}
      &scop attr-code attr-atd-alarm-schedule
      {&attr-batch-edit-code}
      &scop attr-code attr-exp-isPM-last-date
      {&attr-batch-edit-code}

      /* сюда добавлять новые параметры атрибутво клиентов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут клиента &1", p-code) .
      end.
    end.
  end.
end procedure.

/* ################## */
/* атрибуты объектов TH */


/*Набор опций работы с продажей*/
&scop label-attr-autosale "Набор опций работы с продажей"
&scop tooltip-attr-autosale "Набор опций работы с продажей"
&scop user-can-edit-attr-autosale true
&scop output-display-attr-autosale false
&scop other-attr-autosale 'spr-ext=adm\shattr-1.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-autosale 'logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,character,logical,decimal,logical,integer,logical,integer,integer,integer,logical,logical,integer,character'
&scop prop-label-list-attr-autosale 'автом. чтение чеков с кассы после входа в РАСЧЕТ ПРОДАЖИ~
,автом. резервирование после чтения чеков с кассы~
,автом. расчет шапки накл. после входа в РАСЧЕТ ПРОДАЖИ~
,автом. закрытие продажи после удачного резервирования~
,компенсация расход-возврат (в момент закрытия продажи)~
,в продажу чеки только с одним значением курса баз.вал.~
,Значение цены в продаже брать из прайс-листа (не из чека)~
,автом. пр-во необходимых блюд (для РЕСТОРАНА)~
,учет остатков блюд при резервировании (для автом. пр-ва)~
,учет остатков ингридиентов при резервировании (для автом. пр-ва)~
,учет остатков товаров при резервировании (для ТПСИ)~
,в продажу чеки только по фильтру (если задан)~
,контрагенты доп.док-тов~
,уводить в отриц.ост-ки чужой весовой товар на объекте продажи (для ТПСИ)~
,уводить в отриц.ост-ки чужой товар с количеством <~
,уводить в отриц.ост-ки чужой товар по отметке оператора (для ТПСИ)~
,режим ТПСИ~
,Объект-распределитель~
,Кл-к~
,Исп~
,М-р~
,Одна продажа в день~
,Закрытие периода при закрытии продажи~
,Закрывать приход по техпроливу на факт~
,Алгоритмы для разброски сумм по платежам чека'
&scop global-attr-autosale true
&scop host-attr-autosale true
&scop shop-attr-autosale true
&scop store-attr-autosale false
&scop db-attr-autosale false
&scop region-attr-autosale false
&scop batch-edit-attr-autosale  0
&scop level-way-attr-autosale "obj,host,global"
&scop up-way-attr-autosale "autosale,autosale,autosale"
/*бывший конф параметр autosale*/


/*Опции закачки чеков*/
&scop label-attr-get-chk "Опции закачки чеков"
&scop tooltip-attr-get-chk "Опции закачки чеков"
&scop user-can-edit-attr-get-chk true
&scop output-display-attr-get-chk false
&scop other-attr-get-chk 'spr-ext=adm\shattr-2.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-get-chk 'logical,logical,logical,integer,integer,logical,logical,logical,logical,logical,logical,integer,logical':U
&scop prop-label-list-attr-get-chk '~
брать курсы валют в чек из спула~
,номер магазина для чеков брать из спулов~
,использовать смены на кассе~
,виртуальные смены~
,Время начала пересменки в магазине~
,использовать маски ДК при приеме чеков с касс для неперсонифицированных карт~
,принимать специф.чеки АЗК~
,использовать маски ДК при приеме чеков с касс для персонифицированных карт~
,принимать аннулированные чеки~
,НЕТ ПРИЕМА ЧЕКОВ В МАГАЗИНЕ~
,принимать чеки со 100% скидкой~
,<НУЛЕВОЙ> кассир~
,принимать чеки z-отчета~
'
&scop global-attr-get-chk true
&scop host-attr-get-chk true
&scop shop-attr-get-chk true
&scop store-attr-get-chk false
&scop db-attr-get-chk false
&scop region-attr-get-chk false
&scop batch-edit-attr-get-chk  0
&scop level-way-attr-get-chk "obj,host,global"
&scop up-way-attr-get-chk "get-chk,get-chk,get-chk"

/*бывший конф параметры cas-curs,hnum,cas-shft,v-shft,t-shft,dc-mask,ptrl-check,card-by-mask,annu-check,no-get-chk,is-100-discnt*/


/*Опции интерфейса при работе с чеками*/
&scop label-attr-chk-view "Опции интерфейса при работе с чеками"
&scop tooltip-attr-chk-view "Опции интерфейса при работе с чеками"
&scop user-can-edit-attr-chk-view true
&scop output-display-attr-chk-view false
&scop other-attr-chk-view 'spr-ext=adm\shattr-3.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-chk-view 'logical,logical,logical,character,logical':U
&scop prop-label-list-attr-chk-view '~
Разрешена смена товара в чеке (при редакт. чека) на товар с другой ценой~
,Динамич. сбор инф по чекам и показ ее в пиктограммах главного меню~
,Видна кнопка <Cпецификация> в списке чеков - запуск заказной печати~
,Список префиксов номеров платежных карт ПОЛНОСТЬЮ показываемых в интерфейсе~
,Разрешена смена ДК при редактировании чека~
'
&scop global-attr-chk-view true
&scop host-attr-chk-view true
&scop shop-attr-chk-view true
&scop store-attr-chk-view false
&scop db-attr-chk-view false
&scop region-attr-chk-view false
&scop batch-edit-attr-chk-view  0
&scop level-way-attr-chk-view "obj,host,"
&scop up-way-attr-chk-view "chk-view,chk-view,chk-view"

/*бывший конф параметры ch-bc-bk chk-inf chk-spfc paycardv dc-change*/



/*Общие опции коммуникации с кассами*/
&scop label-attr-cd-sending "Общие опции коммуникации с кассами"
&scop tooltip-attr-cd-sending "Общие опции коммуникации с кассами"
&scop user-can-edit-attr-cd-sending true
&scop output-display-attr-cd-sending false
&scop other-attr-cd-sending 'spr-ext=adm\shattr-4.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-sending 'logical,logical,integer,character,logical,character':U
&scop prop-label-list-attr-cd-sending '~
Пересылка товаров на кассу только полным списком~
,Отключена автоматическая передача товаров на кассы~
,Кол-во записей в пакете для пересылки на кассы~
,Тип касс ПО УМОЛЧАНИЮ~
,Докачивать чеки в продажу после чтения с кассы или завершения чека в IBS TH POS~
,Маски коротких кодов~
'
&scop global-attr-cd-sending true
&scop host-attr-cd-sending true
&scop shop-attr-cd-sending true
&scop store-attr-cd-sending false
&scop db-attr-cd-sending false
&scop region-attr-cd-sending false
&scop batch-edit-attr-cd-sending  0
&scop prop-tooltip-list-attr-cd-sending ",,,,В маске цифрами указывается префикс, который отрезается при передаче кодов на кассы , а звездочками количество символов короткого кода . Пример ввода 777***"
&scop level-way-attr-cd-sending "obj,host,global"
&scop up-way-attr-cd-sending "cd-sending,cd-sending,cd-sending"

/*бывшие параметры alllstcs,noautocs,cdpcknum,dflt-cd*/


/*Опции передачи данных на кассу*/
&scop label-attr-cd-inf-send "Опции передачи данных на кассу"
&scop tooltip-attr-cd-inf-send "Вид и набор передаваемой на кассу информации, используемый более чем для одного типа касс"
&scop user-can-edit-attr-cd-inf-send true
&scop output-display-attr-cd-inf-send false
&scop other-attr-cd-inf-send 'spr-ext=adm\shattr-5.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-inf-send 'logical,logical,logical,logical,character,integer,logical,character,character,character':U
&scop prop-label-list-attr-cd-inf-send '~
Передача налогов на кассу~
,Передача основного названия товара на кассу в две строки~
,Как основн. назв. при передаче на кассу - англ. название товара или артикул~
,Как дополн. назв. при передаче на кассу - локальный код товара или код партии~
,Дополн.название на кассу~
,Категорийная/количественная скидка~
,На кассу передавать только типы касс. платежей с атрибутом ИСПОЛЬЗУЕТСЯ~
,Способ задания временной скидки~
,Способ задания категорийной скидки~
,Код внешней системы для передачи соответствий на кассу~
'
&scop global-attr-cd-inf-send true
&scop host-attr-cd-inf-send true
&scop shop-attr-cd-inf-send true
&scop store-attr-cd-inf-send false
&scop db-attr-cd-inf-send false
&scop region-attr-cd-inf-send false
&scop batch-edit-attr-cd-inf-send  0
&scop level-way-attr-cd-inf-send "obj,host,global"
&scop up-way-attr-cd-inf-send "cd-inf-send,cd-inf-send,cd-inf-send"

/*бывшие параметры    tax-cass,nam-2str,nam-artc,cod-pcod,name-2cd,amntdisc,cp-is-use*/



/*Параметры работы с весами*/
&scop label-attr-scale-inf "Параметры работы с весами"
&scop tooltip-attr-scale-inf "Данные, необходимые для работы весов"
&scop user-can-edit-attr-scale-inf true
&scop output-display-attr-scale-inf false
&scop other-attr-scale-inf 'spr-ext=adm\shattr-6.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-scale-inf 'character,character,character,integer,logical':U
&scop prop-label-list-attr-scale-inf '~
Разрешенные типы весов~
,Название программ для работы с весами~
,Номера весов на объекте~
,Установка сроков годности вес.товара при приходе и переоценке~
,Отключена автоматическая передача товаров на весы~
'
&scop global-attr-scale-inf false
&scop host-attr-scale-inf false
&scop shop-attr-scale-inf true
&scop store-attr-scale-inf false
&scop db-attr-scale-inf false
&scop region-attr-scale-inf false
&scop batch-edit-attr-scale-inf  0
&scop level-way-attr-scale-inf "obj,,"
&scop up-way-attr-scale-inf "scale-inf,,"
/*бывшие параметры    scales-type,scales-pr,scallist,sclin-ld,noauto-scls  */



/*Параметры POS IBM*/
&scop label-attr-cd-type-ibm "Параметры POS IBM"
&scop tooltip-attr-cd-type-ibm "Настроечные параметры, необходимые для работы POS IBM"
&scop user-can-edit-attr-cd-type-ibm true
&scop output-display-attr-cd-type-ibm false
&scop other-attr-cd-type-ibm 'cd/spr-ext=adm\shattr-7.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-ibm 'integer,integer,integer,logical,logical,integer,character,character':U
&scop prop-label-list-attr-cd-type-ibm '~
Код нац.вал. НА КАССЕ~
,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1)~
,Прием чеков с продажами по группам~
,Тип спула~
,Прием чеков с продажами по группам~
,Многовалютные НАЛИЧНЫЕ~
,Выделение ставок НДС в чеке~
,Соответствие ставок НДС категориям налога на кассе~
,Спецгруппы в справочнике суммовых групп'
&scop global-attr-cd-type-ibm true
&scop host-attr-cd-type-ibm true
&scop shop-attr-cd-type-ibm true
&scop store-attr-cd-type-ibm false
&scop db-attr-cd-type-ibm false
&scop region-attr-cd-type-ibm false
&scop batch-edit-attr-cd-type-ibm  0
&scop level-way-attr-cd-type-ibm "obj,host,global"
&scop up-way-attr-cd-type-ibm "cd-type-ibm,cd-type-ibm,cd-type-ibm"

/*бывшие параметры   cdtaxlst  cd-vat ibmgroup  ibmnalc ibmrubc ibmspool   */



/*Параметры POS IPC-SERVIS+*/
&scop label-attr-cd-type-ipc-servispl "Параметры POS IPC-SERVIS+"
&scop tooltip-attr-cd-type-ipc-servispl "Настроечные параметры, необходимые для работы POS SERVISPL"
&scop user-can-edit-attr-cd-type-ipc-servispl true
&scop output-display-attr-cd-type-ipc-servispl false
&scop other-attr-cd-type-ipc-servispl 'cd/spr-ext=adm\shattr-8.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-ipc-servispl 'integer,integer,character,integer,character,character,character,integer':U
&scop prop-label-list-attr-cd-type-ipc-servispl '~
Код валюты соответствующий баз. вал. КАССЫ~
,Тип касс.платежа НАЛИЧНЫЕ с кодом валюты равным коду баз. валюты НА КАССЕ~
,Код дополнительной валюты для прейскурантов~
,Префикс весового бар-кода~
,Список кодов платежей по картам на кассе~
,Список типов касс.платежей по картам~
,Список валют для типов касс.платежей по картам~
,Префикс штучного бар-кода для весов~
'
&scop global-attr-cd-type-ipc-servispl true
&scop host-attr-cd-type-ipc-servispl true
&scop shop-attr-cd-type-ipc-servispl true
&scop store-attr-cd-type-ipc-servispl false
&scop db-attr-cd-type-ipc-servispl false
&scop region-attr-cd-type-ipc-servispl false
&scop batch-edit-attr-cd-type-ipc-sevispl  0
&scop level-way-attr-cd-type-ipc-servispl "obj,host,global"
&scop up-way-attr-cd-type-ipc-servispl "cd-type-ipc-servispl,cd-type-ipc-servispl,cd-type-ipc-servispl"

/*бывшие параметры
ipcsbasc,ipcspayn,ipcsdobc,ipcscpfx,ipcsccrd,ipcstcrd,ipcscurc,ipcpgfx */


/*Параметры POS NCR-GM*/
&scop label-attr-cd-type-NCR-GM "Параметры POS NCR-GM"
&scop tooltip-attr-cd-type-NCR-GM "Настроечные параметры, необходимые для работы POS NCR-GM"
&scop user-can-edit-attr-cd-type-NCR-GM true
&scop output-display-attr-cd-type-NCR-GM false
&scop other-attr-cd-type-NCR-GM 'cd/spr-ext=adm\shattr-9.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-ncr-gm 'integer,character,character,integer':U
&scop prop-label-list-attr-cd-type-ncr-gm '~
Префикс весового бар-кода~
,Приоритеты скидок на товар при наличии скидок неск. типов~
,Расположение резервных копий неизменяемых <ручных настроек> для кассы~
,Префикс штучного бар-кода для весов~
'
&scop global-attr-cd-type-ncr-gm true
&scop host-attr-cd-type-ncr-gm true
&scop shop-attr-cd-type-ncr-gm true
&scop store-attr-cd-type-ncr-gm false
&scop db-attr-cd-type-ncr-gm false
&scop region-attr-cd-type-ncr-gm false
&scop batch-edit-attr-cd-type-NCR-GM  0
&scop level-way-attr-cd-type-ncr-gm "obj,host,global"
&scop up-way-attr-cd-type-ncr-gm "cd-type-ncr-gm,cd-type-ncr-gm,cd-type-ncr-gm"

/*бывшие параметры  ncrscpfx,ncrdrank,save-param,ncrpgpfx  */


/*Параметры POS NCR-AS@R*/
&scop label-attr-cd-type-NCR-AS-R "Параметры POS NCR-AS@R"
&scop tooltip-attr-cd-type-NCR-AS-R "Настроечные параметры, необходимые для работы POS NCR-AS@R"
&scop user-can-edit-attr-cd-type-NCR-AS-R true
&scop output-display-attr-cd-type-NCR-AS-R false
&scop other-attr-cd-type-NCR-AS-R 'cd/spr-ext=adm\shattr14.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-ncr-as-r 'integer,character,character,integer':U
&scop prop-label-list-attr-cd-type-ncr-as-r '~
Префикс весового бар-кода~
,Приоритеты скидок на товар при наличии скидок неск. типов~
,Расположение резервных копий неизменяемых <ручных настроек> для кассы~
,Префикс штучного бар-кода для весов~
'
&scop global-attr-cd-type-ncr-as-r true
&scop host-attr-cd-type-ncr-as-r true
&scop shop-attr-cd-type-ncr-as-r true
&scop store-attr-cd-type-ncr-as-r false
&scop db-attr-cd-type-ncr-as-r false
&scop region-attr-cd-type-ncr-as-r false
&scop batch-edit-attr-cd-type-NCR-AS-R  0
&scop level-way-attr-cd-type-ncr-as-r "obj,host,global"
&scop up-way-attr-cd-type-ncr-as-r "cd-type-ncr-as-r,cd-type-ncr-as-r,cd-type-ncr-as-r"

/*бывшие параметры  ncrscpfx,ncrdrank,save-param,ncrpgpfx  */


/*Параметры POS MAGIA-XML*/
&scop label-attr-cd-type-magia-xml "Параметры POS MAGIA-XML"
&scop tooltip-attr-cd-type-magia-xml "Настроечные параметры, необходимые для работы POS MAGIA-XML"
&scop user-can-edit-attr-cd-type-magia-xml true
&scop output-display-attr-cd-type-magia-xml false
&scop other-attr-cd-type-magia-xml 'cd/spr-ext=adm\shattr10.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-magia-xml 'integer,integer,integer,character,character,character,character,character,character':U
&scop prop-label-list-attr-cd-type-magia-xml '~
Тип касс. платежа для безналичной оплаты НА КАССЕ~
,Тип касс. платежа для НЕОПЛАЧЕННОГО  НА КАССЕ~
,Тип касс. платежа для чеков VIP и представит. расходов~
,Код списания для возврата-списания строки чека~
,Код списания для списания строки чека~
,Код списания для возврата-списания целого чека~
,Код списания для cписания всего чека~
,Код списания для возврата-списания заказа~
,Код списания для списания заказа'
&scop global-attr-cd-type-magia-xml true
&scop host-attr-cd-type-magia-xml true
&scop shop-attr-cd-type-magia-xml true
&scop store-attr-cd-type-magia-xml false
&scop db-attr-cd-type-magia-xml false
&scop region-attr-cd-type-magia-xml false
&scop batch-edit-attr-magia-XML  0
&scop level-way-attr-cd-type-magia-xml "obj,host,global"
&scop up-way-attr-cd-type-magia-xml "cd-type-magia-xml,cd-type-magia-xml,cd-type-magia-xml"

/*бывшие параметры  mag-bnal,magnopay,mag-vip,ret-item,wro-item,ret-chk,wro-chk,ret-ord,wro-ord  */


/*Параметры POS OMRON*/
&scop label-attr-cd-type-omron "Параметры POS OMRON"
&scop tooltip-attr-cd-type-omron "Настроечные параметры, необходимые для работы POS OMRON"
&scop user-can-edit-attr-cd-type-omron true
&scop output-display-attr-cd-type-omron false
&scop other-attr-cd-type-omron 'cd/spr-ext=adm\shattr11.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-omron 'integer,integer,integer,character,character':U
&scop prop-label-list-attr-cd-type-omron '~
Код валюты соответствующий баз. вал. КАССЫ~
,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ~
,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ~
,Список кодов типов касс.платежа соответствующих типам платежа на кассе~
,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'
&scop global-attr-cd-type-omron true
&scop host-attr-cd-type-omron true
&scop shop-attr-cd-type-omron true
&scop store-attr-cd-type-omron false
&scop db-attr-cd-type-omron false
&scop region-attr-cd-type-omron false
&scop batch-edit-attr-cd-type-omron  0
&scop level-way-attr-cd-type-omron "obj,host,global"
&scop up-way-attr-cd-type-omron "cd-type-omron,cd-type-omron,cd-type-omron"

/*бывшие параметры  omrbase,omrnal,omrntnl,omrpayl,omrcurl*/

/*Параметры POS OMRON-NEW*/
&scop label-attr-cd-type-omron-new "Параметры POS OMRON-NEW"
&scop tooltip-attr-cd-type-omron-new "Настроечные параметры, необходимые для работы POS OMRON-NEW"
&scop user-can-edit-attr-cd-type-omron-new true
&scop output-display-attr-cd-type-omron-new false
&scop other-attr-cd-type-omron-new 'cd/spr-ext=adm\shattr12.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-omron-new 'integer,integer,integer,character,character':U
&scop prop-label-list-attr-cd-type-omron-new '~
Код валюты соответствующий баз. вал. КАССЫ~
,Тип кассового платежа соответствующий оплате <НАЛИЧНЫЕ> НА КАССЕ~
,Тип кассового платежа соответствующий оплате БЕЗНАЛИЧНЫЕ НА КАССЕ~
,Список кодов типов касс.платежа соответствующих типам платежа на кассе~
,Список кодов валют типов касс.платежа соответствующих типам платежа на кассе'
&scop global-attr-cd-type-omron-new true
&scop host-attr-cd-type-omron-new true
&scop shop-attr-cd-type-omron-new true
&scop store-attr-cd-type-omron-new false
&scop db-attr-cd-type-omron-new false
&scop region-attr-cd-type-omron-new false
&scop batch-edit-attr-cd-type-omron-new  0
&scop level-way-attr-cd-type-omron-new "obj,host,gloabl"
&scop up-way-attr-cd-type-omron-new "cd-type-omron-new,cd-type-omron-new,cd-type-omron-new"
/*бывшие параметры  omrnbase,omrnnal,omrnntnl,omrnpayl,omrncurl */


/*Параметры POS IBM-XML*/
&scop label-attr-cd-type-IBM-XML "Параметры POS IBM-XML"
&scop tooltip-attr-cd-type-IBM-XML "Настроечные параметры, необходимые для работы POS IBM-XML"
&scop user-can-edit-attr-cd-type-IBM-XML true
&scop output-display-attr-cd-type-IBM-XML false
&scop other-attr-cd-type-ibm-XML 'cd/spr-ext=adm\shattr13.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-ibm-XML 'integer,integer,integer,logical,logical,integer,character,character':U
&scop prop-label-list-attr-cd-type-ibm-XML '~
Код валюты соответствующий баз. вал. КАССЫ~
,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1)~
,Код платежа при оплате НАЛИЧНЫМИ CCM~
,прием чеков с продажами по группам~
,Многовалютные НАЛИЧНЫЕ~
,Выделение ставок НДС в чеке~
,Соответствие ставок НДС категориям налога на кассе~
,Спецгруппы в справочнике суммовых групп'
&scop global-attr-cd-type-ibm-XML true
&scop host-attr-cd-type-ibm-XML true
&scop shop-attr-cd-type-ibm-XML true
&scop store-attr-cd-type-ibm-XML false
&scop db-attr-cd-type-ibm-XML false
&scop region-attr-cd-type-ibm-XML false
&scop batch-edit-attr-cd-type-IBM-XML  0
&scop level-way-attr-cd-type-ibm-xml "obj,host,global"
&scop up-way-attr-cd-type-ibm-xml "cd-type-ibm-xml,cd-type-ibm-xml,cd-type-ibm-xml"

/*ibmrubc,ibmnalc,ibm-ccm,ibmgroup,cd-vat,cdtaxlst,specgrp*/


/*Параметры POS R-keeper*/
&scop label-attr-cd-type-r-keeper "Параметры POS R-Keeper"
&scop tooltip-attr-cd-type-r-keeper "Настроечные параметры, необходимые для работы POS R-KEEPER"
&scop user-can-edit-attr-cd-type-r-keeper true
&scop output-display-attr-cd-type-r-keeper false
&scop other-attr-cd-type-r-keeper 'cd/spr-ext=adm\shattr16.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-r-keeper 'character,character,character':U
&scop prop-label-list-attr-cd-type-r-keeper '~
Список соответствий типов кассовых платежей~
,Список соответствий идентификатор скидки на кассе-правило скидки в IBS TH~
,Формат даты при экспорте на кассу'
&scop global-attr-cd-type-r-keeper true
&scop host-attr-cd-type-r-keeper true
&scop shop-attr-cd-type-r-keeper true
&scop store-attr-cd-type-r-keeper false
&scop db-attr-cd-type-r-keeper false
&scop region-attr-cd-type-r-keeper false
&scop batch-edit-attr-cd-type-r-keeper  0
&scop level-way-attr-cd-type-r-keeper "obj,host,global"
&scop up-way-attr-cd-type-r-keeper "cd-type-r-keeper,cd-type-r-keeper,cd-type-r-keeper"
/*cash-pay-list,dis-rule-list,date-format*/


/*Параметры POS MARIA*/
&scop label-attr-cd-type-maria "Параметры Кассы MARIA"
&scop tooltip-attr-cd-type-maria "Настроечные параметры, необходимые для работы кассы MARIA"
&scop user-can-edit-attr-cd-type-maria true
&scop output-display-attr-cd-type-maria false
&scop other-attr-cd-type-maria 'cd/spr-ext=adm\shattr19.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-maria 'character,character,character,character,character,character':U
&scop prop-label-list-attr-cd-type-maria '~
Соответствие ставок НДС категориям налога на кассе~
,Соответствие типов касс.платежей для сопут.товары~
,Соответствие типов касс.платежей для топлива~
,Соответствие моделей скидок НА КАССЕ правилам скидок в IBS TH~
,Приоритеты скидок на товар~
,Приоритеты скидок на группы товаров'
&scop global-attr-cd-type-maria true
&scop host-attr-cd-type-maria true
&scop shop-attr-cd-type-maria true
&scop store-attr-cd-type-maria false
&scop db-attr-cd-type-maria false
&scop region-attr-cd-type-maria false
&scop batch-edit-attr-cd-type-maria 0
&scop level-way-attr-cd-type-maria "obj,host,global"
&scop up-way-attr-cd-type-maria "cd-type-maria,cd-type-maria,cd-type-maria"

/*cdtaxlst,mariapayg,mariapayp,dr-list,drgrouprank,drgdsrank*/


/*Параметры POS autotank*/
&scop label-attr-cd-type-autotank "Параметры POS autotank"
&scop tooltip-attr-cd-type-autotank "Настроечные параметры, необходимые для работы POS autotank"
&scop user-can-edit-attr-cd-type-autotank true
&scop output-display-attr-cd-type-autotank false
&scop other-attr-cd-type-autotank 'cd/spr-ext=adm\shattr41.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-autotank 'character,logical,character':U
&scop prop-label-list-attr-cd-type-autotank '~
Список соответствий типов кассовых платежей~
,Прием чеков с продажами по группам~
,Спецгруппы в справочнике суммовых групп'

&scop global-attr-cd-type-autotank true
&scop host-attr-cd-type-autotank true
&scop shop-attr-cd-type-autotank true
&scop store-attr-cd-type-autotank false
&scop db-attr-cd-type-autotank false
&scop region-attr-cd-type-autotank false
&scop batch-edit-attr-cd-type-autotank  0
&scop level-way-attr-cd-type-autotank "obj,host,global"
&scop up-way-attr-cd-type-autotank "cd-type-autotank,cd-type-autotank,cd-type-autotank"
/*cash-pay-list,ibmgroup,specgrp*/
/*cash-pay-list*/


/* НАстройки  межфирменного перемещения для ТПСИ */
&scop label-attr-alias-tpsi           "Настройки межфирменного перемещения через ТПСИ"
&scop tooltip-attr-alias-tpsi         "Настройки межфирменного перемещения через ТПСИ"
&scop user-can-edit-attr-alias-tpsi   true
&scop output-display-attr-alias-tpsi  true
&scop other-attr-alias-tpsi           'spr-ext=adm\als-tppr.w':U
&scop prop-type-list-attr-alias-tpsi 'integer,Character':U
&scop prop-label-list-attr-alias-tpsi 'Тип цены при продаже товара другой фирмой~
,Объект-посредник для цены межфирменного перемещения'
&scop global-attr-alias-tpsi true
&scop host-attr-alias-tpsi true
&scop shop-attr-alias-tpsi true
&scop store-attr-alias-tpsi true
&scop db-attr-alias-tpsi false
&scop region-attr-alias-tpsi false
&scop batch-edit-attr-alias-tpsi  0
&scop level-way-attr-alias-tpsi "obj,host,global"
&scop up-way-attr-alias-tpsi "alias-tpsi,alias-tpsi,alias-tpsi"


/* гарантийный запас по АBCанализу в днях */
&scop type-attr-abc-sale-day            {&type-char}
&scop format-attr-abc-sale-day          "x(40)"
&scop label-attr-abc-sale-day           "Гарантийный запас по АBC-анализу в днях"
&scop tooltip-attr-abc-sale-day         "Гарантийный запас по АBC-анализу в днях"
&scop user-can-edit-attr-abc-sale-day   true
&scop output-display-attr-abc-sale-day  true
&scop other-attr-abc-sale-day           'spr-ext=adm\abc-gar.w':U
&scop prop-type-list-attr-abc-sale-day 'integer,integer,integer,integer,integer,integer':U
&scop prop-label-list-attr-abc-sale-day 'A,B,C,D,E,F'
&scop global-attr-abc-sale-day true
&scop host-attr-abc-sale-day true
&scop shop-attr-abc-sale-day true
&scop store-attr-abc-sale-day true
&scop db-attr-abc-sale-day false
&scop region-attr-abc-sale-day false
&scop batch-edit-attr-abc-sale-day  0
&scop level-way-attr-abc-sale-day "obj,host,global"
&scop up-way-attr-abc-sale-day "abc-sale-day,abc-sale-day,abc-sale-day"


/* Общие параметры по АBCанализу */
&scop type-attr-abc-global            {&type-char}
&scop format-attr-abc-global          "x(40)"
&scop label-attr-abc-global           "Глобальные настройки АВС-анализа"
&scop tooltip-attr-abc-global         "Общие параметры настройки АВС-анализа"
&scop user-can-edit-attr-abc-global   true
&scop output-display-attr-abc-global  true
&scop other-attr-abc-global           'spr-ext=gbl\assortpa.w':U
&scop prop-type-list-attr-abc-global  'character,character,character,character':U
&scop prop-label-list-attr-abc-global 'ABC-анализ - способ проведения,Количество параметров для ABC-анализа,Проценты по умолчанию для ABC-анализа (простого). Уровни ранжирования,Проценты по умолчанию по Двухуровневому ABC-анализу'
&scop prop-list-attr-abc-global       'abc-mode,abc-type,abc-one,abc-two'
&scop global-attr-abc-global true
&scop host-attr-abc-global false
&scop shop-attr-abc-global false
&scop store-attr-abc-global false
&scop db-attr-abc-global false
&scop region-attr-abc-global false
&scop batch-edit-attr-abc-global  0
&scop attr-abc-global-abc-mode_tooltip Способ проведения АВС : простой и двухпроходный (анализ в два прохода; первый проход деление на две группы; второй проход - простой анализ 1й группы и отсечение низкого процента во 2й группе)
&scop attr-abc-global-abc-type_tooltip Количество уровней ранжирования для ABC-анализа
&scop attr-abc-global-abc-one_tooltip  Количество процентов определяется типом АВС-анализа
&scop attr-abc-global-abc-two_tooltip  Первая пара процентов - деление первого уровня; далее идут проценты ABC первой группы второго уровня. Последний третий элемент в этом списке процент отсекания во второй группе второго уровня.
&scop prop-tooltip-list-attr-abc-global {&attr-abc-global-abc-mode_tooltip},{&attr-abc-global-abc-type_tooltip},{&attr-abc-global-abc-one_tooltip},{&attr-abc-global-abc-two_tooltip}
&scop level-way-attr-abc-global ",,global"
&scop up-way-attr-abc-global ",,abc-global"


/* Общие параметры по ЗАКАЗАМ */
&scop type-attr-ord-global            {&type-char}
&scop format-attr-ord-global          "x(40)"
&scop label-attr-ord-global           "Глобальные настройки для ЗАКАЗОВ"
&scop tooltip-attr-ord-global         "Общие параметры настройки Заказов"
&scop user-can-edit-attr-ord-global   true
&scop output-display-attr-ord-global  true
&scop other-attr-ord-global           'spr-ext=gbl\orderpa.w':U
&scop prop-type-list-attr-ord-global  'logical,logical,logical,logical,logical,integer,logical':U
&scop prop-label-list-attr-ord-global 'Логировать расчет заказа,Заявки типа ОФ формируются в офисе,В заказах ОО учитывать остаток на объектах-поставщиках,Заказы типа ОП работают по полной схеме,MIN остаток учитывается в днях,Количество дней до заказа,Цикличные заказы по всем товарам группы из спецификации'
&scop prop-list-attr-ord-global       'ord-log,ord-ofof,ord-oobj,ord-op,ord-min-ost-day,ordshipd,ordcyclg'
&scop global-attr-ord-global true
&scop host-attr-ord-global false
&scop shop-attr-ord-global false
&scop store-attr-ord-global false
&scop db-attr-ord-global false
&scop region-attr-ord-global false
&scop batch-edit-attr-ord-global  0
&scop attr-ord-global-ord-log_tooltip  (ord-log) Логировать расчет заказа в файл рабочей директории order_raschet.txt
&scop attr-ord-global-ord-ofof_tooltip (ord-ofof) Если - да` то заявки типа ОФ формируются только в офисе`а не на объектах
&scop attr-ord-global-ord-oobj_tooltip (ord-oobj) Если - да` то при распределении заказа ОО количество товара заказывается не больше` чем остаток на объекте-поставщике
&scop attr-ord-global-ord-op_tooltip   (ord-op) Заказы ОП проходят согласование в офисе и возвращаются назад на объекты с отказом или одобренными
&scop attr-ord-global-ord-min-ost-day_tooltip   (min-ost-day) При расчете заказа параметр Минимальный остаток на объекте или на фирме будет учитываться в днях` а не в штуках
&scop attr-ord-global-ordshipd_tooltip   (ordshipd) Дата ЗАКАЗ НА устанавливается по формуле СЕГОДНЯ + УКАЗАННОЕ КОЛИЧЕСТВО ДНЕЙ
&scop attr-ord-global-ordcyclg_tooltip   (ordcyclg) Цикличные заказы строятся по специфмикации по всей группе товаров` входящий в копируемый заказ
&scop prop-tooltip-list-attr-ord-global  {&attr-ord-global-ord-log_tooltip},{&attr-ord-global-ord-ofof_tooltip},{&attr-ord-global-ord-oobj_tooltip},{&attr-ord-global-ord-op_tooltip},{&attr-ord-global-ord-min-ost-day_tooltip},{&attr-ord-global-ordshipd_tooltip},{&attr-ord-global-ordcyclg_tooltip}
&scop level-way-attr-ord-global ",,global"
&scop up-way-attr-ord-global ",,ord-global"


/* параметры по ЗАКАЗАМ по объектам */
&scop type-attr-ord-obj            {&type-char}
&scop format-attr-ord-obj          "x(40)"
&scop label-attr-ord-obj           "Настройки для ЗАКАЗОВ"
&scop tooltip-attr-ord-obj         "Параметры настройки Заказов по объектам"
&scop user-can-edit-attr-ord-obj   true
&scop output-display-attr-ord-obj  true
&scop other-attr-ord-obj           'spr-ext=gbl\orderpa.w':U
&scop prop-type-list-attr-ord-obj  'logical,character,decimal,logical,decimal':U
&scop prop-label-list-attr-ord-obj 'Спрашивать о цене перемещения ОРЦ ,Объект РЦ,% отклонения принимаемого количества весового товара в ПОСТАВКЕ,По Заказу ОП только одна накладная,% исполнения заказа при котором он закрывается автоматически'
&scop prop-list-attr-ord-obj       'ord-askp,ord-obj-rc,ord-wgt-div-prc,ord-11,ord-comp-prc'
&scop global-attr-ord-obj true
&scop host-attr-ord-obj true
&scop shop-attr-ord-obj true
&scop store-attr-ord-obj true
&scop db-attr-ord-obj false
&scop region-attr-ord-obj false
&scop batch-edit-attr-ord-obj  0
&scop attr-ord-obj-ord-askp_tooltip   (ord-askp) В ОРЦ спрашивать по какой цене формировать заказ: по цене объекта или объекта поставщика
&scop attr-ord-obj-ord-obj-rc_tooltip (ord-obj-rc) Номер объекта ОРЦ по умолчанию
&scop attr-ord-obj-ord-wgt-div-prc_tooltip  (ord-wgt-div-prc) Процент отклонения количества весового товара в большую сторону от документарного количества  при создании документа ПОСТАВКИ
&scop attr-ord-obj-ord-11_tooltip  (ord-11) По одному заказу вручную можно создать одну поставку и только одну приходную накладную
&scop attr-ord-obj-ord-comp-prc_tooltip  (ord-comp-prc) Процент исполнения заказа при котором он закрывается автоматически
&scop prop-tooltip-list-attr-ord-obj {&attr-ord-obj-ord-askp_tooltip},{&attr-ord-obj-ord-obj-rc_tooltip},{&attr-ord-obj-ord-wgt-div-prc_tooltip},{&attr-ord-obj-ord-11_tooltip},{&attr-ord-obj-ord-comp-prc_tooltip}
&scop level-way-attr-ord-obj "obj,host,global"
&scop up-way-attr-ord-obj "ord-obj,ord-obj,ord-obj"


/* Общие параметры по Взаиморасчетам ФО-новости */
&scop type-attr-fin-global            {&type-char}
&scop format-attr-fin-global          "x(40)"
&scop label-attr-fin-global           "Глобальные настройки для Взаиморасчетов"
&scop tooltip-attr-fin-global         "Общие параметры настройки для Взаиморасчетов"
&scop user-can-edit-attr-fin-global   true
&scop output-display-attr-fin-global  true
&scop other-attr-fin-global           'spr-ext=gbl\finglpa.w':U
&scop prop-type-list-attr-fin-global  'integer,integer,logical,integer,logical,logical,integer':U
&scop prop-label-list-attr-fin-global 'Где могут создаваться ФО покупателей,Как ходят ФО поставщиков по новостям,Дата закрытия ФО соответствует дате закрытия накладной,Режим работы ФО с мастер договорами,Формирование связи ФО и платежей автоматически при оплате,Удалять связи платежа с ФО автоматом при удалении платежа,Генерировать ФО для:'
&scop prop-list-attr-fin-global       'fo-buyer-nws,fo-supp-nws,fo-fact,fo-mc-mode,add-conn-avt,del-conn-avt,fo-gen'
&scop global-attr-fin-global          true
&scop host-attr-fin-global            false
&scop shop-attr-fin-global            false
&scop store-attr-fin-global           false
&scop db-attr-fin-global           false
&scop region-attr-fin-global          false
&scop batch-edit-attr-fin-global      0
&scop attr-fin-global-fo-buyer-nws_tooltip (fo-buyer-nws) Где могут создаваться ФО покупателей
&scop attr-fin-global-fo-supp-nws_tooltip  (fo-supp-nws) Как ходят ФО поставщиков по новостям
&scop attr-fin-global-fo-fact-tooltip      (fo-fact) Если параметр включен _то при закрытиии финансового обязательства на ФАКТ дата закрытия будет равна ДАТЕ ФАКТ накладной_ на основе которой и было создано ФО. Если ФО ручное или создано не по накладным дата закрытия = текущая дата объекта
&scop attr-fin-global-fo-mc-mode-tooltip   (fo-mc-mode) 0-Простая старая схема / 1-Мастер договор / 2-Смешанная схема
&scop attr-fin-global-add-conn-avt-tooltip  (add-conn-avt) Если параметр включен _то при при оплате ФО связь с платежем будет формироваться автоматически
&scop attr-fin-global-del-conn-avt-tooltip  (del-conn-avt) Если параметр включен _то при удалении платежа связи платежа с ФО будут удаляться автоматически
&scop attr-fin-global-fo-gen-tooltip       Генерировать ФО для заказов и/или накладных
&scop prop-tooltip-list-attr-fin-global    {&attr-fin-global-fo-buyer-nws_tooltip},{&attr-fin-global-fo-supp-nws_tooltip},{&attr-fin-global-fo-fact-tooltip},{&attr-fin-global-fo-mc-mode-tooltip},{&attr-fin-global-add-conn-avt-tooltip},{&attr-fin-global-del-conn-avt-tooltip},{&attr-fin-global-fo-gen-tooltip}
&scop level-way-attr-fin-global ",,global"
&scop up-way-attr-fin-global ",,fin-global"

/* Объектные параметры по ФИн документам
26/II-2019 не используется. Атрибуты финансовых документов перенесены в БПА
&scop type-attr-fin-doc            {&type-char}
&scop format-attr-fin-doc          "x(40)"
&scop label-attr-fin-doc           "Настройки для Фин.документов"
&scop tooltip-attr-fin-doc         "Настройки для Фин.документов"
&scop user-can-edit-attr-fin-doc   true
&scop output-display-attr-fin-doc  true
&scop other-attr-fin-doc           'spr-ext=adm\shattr39.w':U
&scop prop-type-list-attr-fin-doc  'character,character,integer,character,character,integer,character,character,character,integer,character,character,character,character,integer':U
&scop global-attr-fin-doc          false
&scop host-attr-fin-doc            false
&scop shop-attr-fin-doc            true
&scop store-attr-fin-doc           false
&scop db-attr-fin-doc              false
&scop region-attr-fin-doc          false
&scop batch-edit-attr-fin-doc      0
&scop prop-label-list-attr-fin-doc '~
Суффикс для автоматич.генерации № ПКО~
,Префикс для автоматич.генерации № ПКО~
,Текущий № ПКО (без префикса и суффикса)~
,Суффикс для автоматич.генерации № РКО~
,Префикс для автоматич.генерации № РКО~
,Текущий № ПКО (без префикса и суффикса)~
,Должность руководителя в наличных платежах~
,ФИО руководителя в наличных платежах~
,ФИО гл.бухгалтера в наличных платежах~
,Где ведется Кассовая Книга~
,Как ведется учет~
,Опция заполнения структур.подразд~
,Название структур.подразд~
,Тип структур.подразд~
,Код структур.подразд~
'
&scop level-way-attr-fin-doc "obj,,"
&scop up-way-attr-fin-doc "fin-doc,,"
*/


/* Общие параметры по Накладным и договорам  */
&scop type-attr-contr-in            {&type-char}
&scop format-attr-contr-in          "x(40)"
&scop label-attr-contr-in           "Настройки для Накладных в разрезе ВЗАИМОРАСЧЕТОВ"
&scop tooltip-attr-contr-in         "Настройки для приходных и расходных накладных и договоров в разрезе взаиморасчетов"
&scop user-can-edit-attr-contr-in   true
&scop output-display-attr-contr-in  true
&scop other-attr-contr-in           'spr-ext=gbl\naklpa.w':U
&scop prop-type-list-attr-contr-in  'logical,logical,logical,logical,logical,logical,logical':U
&scop prop-label-list-attr-contr-in 'Договор в ПН с НП,Договор в ПН с СТ,Договор в РН с НП,Договор в РН с СТ,Сверять количества в ПН,Перенумерация ПКО и РКО'
&scop prop-list-attr-contr-in       'contr-in-income-NP,contr-in-income,contr-in-expense-NP,contr-in-expense,contr-qnty-spec,contr-recount'
&scop global-attr-contr-in true
&scop host-attr-contr-in true
&scop shop-attr-contr-in true
&scop store-attr-contr-in true
&scop db-attr-contr-in false
&scop region-attr-contr-in false
&scop batch-edit-attr-contr-in  0
&scop attr-contr-in_contr-in-income-NP_tooltip  Обязательная ссылка на договор в приходной накладной с НП
&scop attr-contr-in_contr-in-income-CPT_tooltip  Обязательная ссылка на договор в приходной накладной с СТ
&scop attr-contr-in_contr-in-expense-NP_tooltip Обязательная ссылка на договор в расходной накладной с НП
&scop attr-contr-in_contr-in-expense-CPT_tooltip Обязательная ссылка на договор в расходной накладной с СТ
&scop attr-contr-in_contr-qnty-spec_tooltip  Сверять количество в ПН по спецификации
&scop attr-contr-in_contr-recount_tooltip  Перенумерация ПКО и РКО
&scop prop-tooltip-list-attr-contr-in        {&attr-contr-in_contr-in-income-NP_tooltip},{&attr-contr-in_contr-in-income_tooltip},{&attr-contr-in_contr-in-expense-NP_tooltip},{&attr-contr-in_contr-in-expense_tooltip},{&attr-contr-in_contr-qnty-spec_tooltip},{&attr-contr-in_contr-recount_tooltype}
&scop level-way-attr-contr-in "obj,host,global"
&scop up-way-attr-contr-in "contr-in,contr-in,contr-in"


/* Складские документы */
&scop type-attr-nakl_par            {&type-char}
&scop format-attr-nakl_par          "x(40)"
&scop label-attr-nakl_par           "Настройки для Складских документов"
&scop tooltip-attr-nakl_par         "Общие Настройки для Складских документов"
&scop user-can-edit-attr-nakl_par   true
&scop output-display-attr-nakl_par  true
&scop other-attr-nakl_par           'spr-ext=gbl\naklpa1.w':U
&scop prop-type-list-attr-nakl_par  'date,logical,integer,integer,logical,logical,logical,logical,decimal,logical,logical,logical,logical,character,logical,logical,logical,logical,logical,logical,logical,character,character,character,character,logical,character,character':U
&scop prop-label-list-attr-nakl_par 'Дата закрытия периода~
,Дата факт = Дате документа (для внешних ПН РН и МФ )~
,Тип заведения НДС по умолчанию~
,Тип заведения НсП по умолчанию~
,Спрашивать о цене перемещения~
,Автокоррекция отрицательных партий по Приходу и Возврату~
,В расход только партии доступные на дату док-та~
,Доверенность для внешней РН и возврата поставщику~
,Коэффициент дорожного налога~
,В ПН заведение по сумме или по цене нельзя изменить~
,Обязательное заведение ПРИЧИНЫ ЗАВЕДЕНИЯ ДОКУМЕНТА~
,Разрешено работать с документами задним числом~
,Запрет на ручной ввод ПН без Заказа~
,Документы-исключения~
,Предупреждение в РН при запрете отриц.остатков о нехватке товара~
,В ПН подставлять НДС из карточки товара~
,Инвойс-отгузка~
,Принудительное округление НДС до 2 знаков после запятой в ПН и РН~
,В ПН Обязательно указывать ГТД для товаров с импортным производителем~
,Запрещен приход при превышении максимальных остатков~
,Помарочный учет движения алкогольной продукции~
,Приход внешний топливо~
,Приход внешний товары~
,Возврат поставщику товары~
,Расход внешний товары~
,Разрешено вводить фактическое количество в статусе Накл-~
,Основания для возврата~
,Причины списания~
'
&scop prop-list-attr-nakl_par 'date-close-period,stfactdt,type-vat,type-slt,intprmvq,minusprt,avail-on-date,proxycrd,factorrt,inp_sum,reasonm,back-date,not-ord,reasonme,neg-ask,vat-goods,inv-ship,round-vat-sum,gtd-to-imp-prod,exc-max-qnty,mark-alchol,attr-PN,attr-mandatory-gds-in-wayb,attr-mandatory-gds-ret-wayb,attr-mandatory-gds-exp-wayb,edit-fact-wayb,reasons-for-return,reasons-write-off'
&scop global-attr-nakl_par true
&scop host-attr-nakl_par   true
&scop shop-attr-nakl_par   true
&scop store-attr-nakl_par  true
&scop db-attr-nakl_par  false
&scop region-attr-nakl_par false
&scop batch-edit-attr-nakl_par  0
&scop attr-nakl_par_date-close-period_tooltip (date-close-period) Дата закрытия периода` нельзя удалять или корректировать на факт документы раньше этой даты
&scop attr-nakl_par_stfactdt_tooltip (stfactdt) При добавлении документов внешнего ПН` РН и межфирменного перемещения устанавливается дата факт равной дате документа. Объект должен быть несменным
&scop attr-nakl_par_type-vat_tooltip (type-vat) Тип заведения НДС по умолчанию
&scop attr-nakl_par_type-slt_tooltip (type-slt) Тип заведения НсП по умолчанию
&scop attr-nakl_par_intprmvq_tooltip (intprmvq) Спрашивать по какой цене делать внутр.расход` по цене источника или приемника
&scop attr-nakl_par_minusprt_tooltip (minusprt) Автоматическая коррекция отрицательных партий по внешнему и внутреннему  приходу и возврату
&scop attr-nakl_par_avail-on-date_tooltip (avail-on-date) В расходе резервируются  только партии доступные на дату док-та
&scop attr-nakl_par_proxycrd_tooltip (proxycrd) Обязательно ли нужно заполнять доверенность для внешнего расхода и возврата поставщику
&scop attr-nakl_par_factorrt_tooltip (factorrt) Для румынской формулы расчета цены
&scop attr-nakl_par_inp_sum_tooltip  (inp_sum)  В ПН заведение по сумме или по цене нельзя изменить
&scop attr-nakl_par_reasonm_tooltip  (reasonm) Обязательное заведение значения поля ПРИЧИНА ЗАВЕДЕНИЯ ДОКУМЕНТА
&scop attr-nakl_par_back-date_tooltip (back-date) Разрешено закрывать и удалять документы задним числом
&scop attr-nakl_par_not-ord_tooltip   (not-ord) Запрещено заводить приходную накладную` она порождается на основе заказа
&scop attr-nakl_par_reasonme_tooltip  (reasonme) Документы - исключения` по ним не Обязательное заведение значения поля ПРИЧИНА ЗАВЕДЕНИЯ ДОКУМЕНТА
&scop attr-nakl_par_neg-ask_tooltip   (neg-ask) При резервированни товара` если отрицательные остатки запрещены и остатка не хватает выдавать предупреждение
&scop attr-nakl_par_vat-goods_tooltip (vat-goods) По-умолчанию в ПН подставлять НДС из карточки товара
&scop attr-nakl_par_inv-ship_tooltip (inv-ship) Требуется заполнять поля инвойс` номер и дату отгрузки в ПН
&scop attr-nakl_par_round-vat-sum_tooltip   (round-vat-sum) В линии накладной округлять НДС до 2 знаков
&scop attr-nakl_par_gtd-to-imp-prod_tooltip   (gtd-to-imp-prod) Запрещено закрытие на факт ПН` если не указана ГТД для товара` у производителя которого стоит атрибут - Импортный производитель
&scop attr-nakl_par_exc-max-qnty_tooltip   (exc-max-qnty) Запрещено закрытие на факт ПН` если после закрытия остатки товара будут больше` чем установленные максимальные остатки на объекте
&scop attr-nakl_par_mark-alchol_tooltip   (mark-alchol) Помарочный учет движения алкогольной продукции
&scop attr-nakl_par_attr-PN_tooltip  (attr-PN) Обязательные атрибуты накладной приход внешний топливо
&scop attr-nakl_par_attr-mandatory-gds-in-wayb_tooltip  (attr-mandatory-gds-in-wayb)  Обязательные атрибуты накладной приход внешний товары
&scop attr-nakl_par_attr-mandatory-gds-ret-wayb_tooltip (attr-mandatory-gds-ret-wayb) Обязательные атрибуты накладной возврат поставщику товары
&scop attr-nakl_par_attr-mandatory-gds-exp-wayb_tooltip (attr-mandatory-gds-exp-wayb) Обязательные атрибуты накладной расход внешний товары
&scop attr-nakl_par_edit-fact-wayb_tooltip (edit-fact-wayb) Разрешено вводить фактическое количество в статусе Накл-
&scop attr-nakl_par_reasons-for-return_tooltip (reasons-for-return) Основания для внешнего расхода по которым будет определяться что делаем возврат поставщику
&scop attr-nakl_par_reasons-write-off_tooltip (reasons-write-off) Причины списания
&scop prop-tooltip-list-attr-nakl_par {&attr-nakl_par_date-close-period_tooltip},~
{&attr-nakl_par_stfactdt_tooltip},~
{&attr-nakl_par_type-vat_tooltip},~
{&attr-nakl_par_type-slt_tooltip},~
{&attr-nakl_par_intprmvq_tooltip},~
{&attr-nakl_par_minusprt_tooltip},~
{&attr-nakl_par_avail-on-date_tooltip},~
{&attr-nakl_par_proxycrd_tooltip},~
{&attr-nakl_par_factorrt_tooltip},~
{&attr-nakl_par_inp_sum_tooltip},~
{&attr-nakl_par_reasonm_tooltip},~
{&attr-nakl_par_back-date_tooltip},~
{&attr-nakl_par_not-ord_tooltip},~
{&attr-nakl_par_reasonme_tooltip},~
{&attr-nakl_par_neg-ask_tooltip},~
{&attr-nakl_par_vat-goods_tooltip},~
{&attr-nakl_par_inv-ship_tooltip},~
{&attr-nakl_par_round-vat-sum_tooltip},~
{&attr-nakl_par_gtd-to-imp-prod_tooltip},~
{&attr-nakl_par_exc-max-qnty_tooltip},~
{&attr-nakl_par_mark-alchol_tooltip},~
{&attr-nakl_par_attr-PN_tooltip},~
{&attr-nakl_par_attr-mandatory-gds-in-wayb_tooltip},~
{&attr-nakl_par_attr-mandatory-gds-ret-wayb_tooltip},~
{&attr-nakl_par_attr-mandatory-gds-exp-wayb_tooltip},~
{&attr-nakl_par_edit-fact-wayb_tooltip},~
{&attr-nakl_par_reasons-for-return_tooltip},~
{&attr-nakl_par_reasons-write-off_tooltip}
&scop level-way-attr-nakl_par "obj,host,global"
&scop up-way-attr-nakl_par "nakl_par,nakl_par,nakl_par"


&scop label-attr-fin-plan           "Плановые цифры денежных средств"
&scop tooltip-attr-fin-plan         "Плановые цифры денежных средств - Взаиморасчеты"
&scop user-can-edit-attr-fin-plan   true
&scop output-display-attr-fin-plan  true
&scop other-attr-fin-plan           '':U
&scop prop-type-list-attr-fin-plan 'decimal,decimal,decimal,decimal':U
&scop prop-label-list-attr-fin-plan 'Остаток на начало дня в кассах,План прихода,Прочие доходы,Прочие расходы'
&scop global-attr-fin-plan false
&scop host-attr-fin-plan false
&scop shop-attr-fin-plan true
&scop store-attr-fin-plan true
&scop db-attr-fin-plan false
&scop region-attr-fin-plan false
&scop batch-edit-attr-fin-plan  0
&scop level-way-attr-fin-plan "obj,,"
&scop up-way-attr-fin-plan "fin-plan,,"


/* Значения по умолчанию для накладных, создаваемых через Радиотерминал  */
&scop label-attr-rt-trn-doc           "Радиотерминал. Значения по умолчанию для создаваемых накладных"
&scop tooltip-attr-rt-trn-doc         "Радиотерминал. Значения по умолчанию для создаваемых накладных"
&scop user-can-edit-attr-rt-trn-doc   true
&scop output-display-attr-rt-trn-doc  true
&scop other-attr-rt-trn-doc 'spr-ext=adm\shattr20.w/init-ext=shattri.p':U
&scop prop-type-list-attr-rt-trn-doc 'integer,integer,integer':U
&scop prop-label-list-attr-rt-trn-doc 'Кладовщик,Оператор,Менеджер'
&scop global-attr-rt-trn-doc true
&scop host-attr-rt-trn-doc true
&scop shop-attr-rt-trn-doc true
&scop store-attr-rt-trn-doc true
&scop db-attr-rt-trn-doc false
&scop region-attr-rt-trn-doc false
&scop batch-edit-attr-rt-trn-doc  0
&scop level-way-attr-rt-trn-doc "obj,host,global"
&scop up-way-attr-rt-trn-doc "rt-trn-doc,rt-trn-doc,rt-trn-doc"


/*Набор опций работы со справочником товаров*/
&scop label-attr-gds-ref "Набор опций работы со справочником товаров"
&scop tooltip-attr-gds-ref "Набор опций работы со справочником товаров"
&scop user-can-edit-attr-gds-ref true
&scop output-display-attr-gds-ref false
&scop other-attr-gds-ref 'spr-ext=adm\shattr21.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-gds-ref 'logical,logical,logical,logical,logical,logical,logical,logical,integer,integer,character,character'
&scop prop-label-list-attr-gds-ref '~
Разрешено добавление товаров с одинаковыми именами~
,Обязательное заведение ДопБК при добавлении товара~
,Выключение повторных ДопБК при появлении новых~
,Запрет повторных ДопБК для одного производителя~
,Запрет повторных ДопБК~
,Импортировать код ТНВЭД в карточку товара~
,Уникальный цифровой артикул`создание доп. БК = артикулу~
,Разрешено создавать глобальный весовые коды~
,Гр.товаров по умолч.~
,Схема хранения фото~
,Опции копирования допинфо по товару ( при соз-дании товара копированием)~
,Заказные поля в экране покупателя~
,Запрещена работа с Доп-БК~
'
&scop prop-list-attr-gds-ref 'dif-nam1,dif-nam2,dpl-off,dif-pdbc,pbc-veto,tnvedimp,unq-artc,is-scgb,dfltggrp,shema-foto,gds-copy,gdsscrvw'
&scop global-attr-gds-ref true
&scop host-attr-gds-ref false
&scop shop-attr-gds-ref false
&scop store-attr-gds-ref false
&scop db-attr-gds-ref false
&scop region-attr-gds-ref false
&scop batch-edit-attr-gds-ref  0
&scop level-way-attr-gds-ref ",,"
&scop up-way-attr-gds-ref ",,gds-ref"
/*бывший конф параметр dif-nam1 dif-nam2 dpl-off dif-pdbc pbc-veto tnvedimp dfltggrp gds-copy gdsscrvw*/


/*Набор опций работы со справочником товаров*/
&scop label-attr-gds-ref_obj "Набор опций работы со справочником товаров в контексте объекта"
&scop tooltip-attr-gds-ref_obj "Набор опций работы со справочником товаров в контексте объекта"
&scop user-can-edit-attr-gds-ref_obj true
&scop output-display-attr-gds-ref_obj false
&scop other-attr-gds-ref_obj 'spr-ext=adm\shattr22.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-gds-ref_obj 'integer,character,logical,character'
&scop prop-label-list-attr-gds-ref_obj '~
Гр.товаров по умолч.~
,Заказные поля в экране покупателя~
,Запрещена работа с Доп-БК~
'
&scop global-attr-gds-ref_obj false
&scop host-attr-gds-ref_obj false
&scop shop-attr-gds-ref_obj true
&scop store-attr-gds-ref_obj true
&scop db-attr-gds-ref_obj false
&scop region-attr-gds-ref_obj false
&scop batch-edit-attr-gds-ref_obj  0
&scop level-way-attr-gds-ref_obj "obj,,global"
&scop up-way-attr-gds-ref_obj "gds-ref_obj,,gds-ref"

/*бывший конф параметр dfltggrp */


/*Набор опций работы со справочником ДК*/
&scop label-attr-dc-ref "Набор опций работы со справочником ДК"
&scop tooltip-attr-dc-ref "Набор опций работы со ДК"
&scop user-can-edit-attr-dc-ref true
&scop output-display-attr-dc-ref false
&scop other-attr-dc-ref 'spr-ext=adm\shattr38.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-dc-ref 'logical,logical'
&scop prop-label-list-attr-dc-ref '~
Разрешено добавление ДК с лидирующими нулями~
,Маскирование ДК~
'
&scop global-attr-dc-ref true
&scop host-attr-dc-ref false
&scop shop-attr-dc-ref true
&scop store-attr-dc-ref false
&scop db-attr-dc-ref false
&scop region-attr-dc-ref false
&scop batch-edit-attr-dc-ref  0
&scop level-way-attr-dc-ref "obj,,global"
&scop up-way-attr-dc-ref "dc-ref,,dc-ref"

/*Набор опций работы со справочником клиентов*/
&scop label-attr-cli-all "Набор опций работы со справочником клиентов"
&scop tooltip-attr-cli-all "Набор опций работы со справочником клиентов"
&scop user-can-edit-attr-cli-all true
&scop output-display-attr-cli-all false
&scop other-attr-cli-all 'spr-ext=adm\shattr23.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cli-all 'integer,logical'
&scop prop-label-list-attr-cli-all '~
Опции уникальности {&abbr-nc_inn}~
,Разрешен ввод некорректного {&abbr-nc_inn}'
&scop global-attr-cli-all true
&scop host-attr-cli-all false
&scop shop-attr-cli-all false
&scop store-attr-cli-all false
&scop db-attr-cli-all false
&scop region-attr-cli-all false
&scop batch-edit-attr-cli-all  0
&scop level-way-attr-cli-all ",,global"
&scop up-way-attr-cli-all ",,cli-all"

/*бывший конф параметр inn-uniq nocorinn*/

/*Набор опций работы со справочником типов касс платежей*/
&scop label-attr-cashpays "Набор опций работы со справочником типов кассовых платежей"
&scop tooltip-attr-cashpays "Набор опций работы со справочником типов кассовых платежей"
&scop user-can-edit-attr-cashpays true
&scop output-display-attr-cashpays false
&scop other-attr-cashpays 'spr-ext=adm\shattr24.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cashpays 'character'
&scop prop-label-list-attr-cashpays '~
Определение групп типов кассовых платежей'
&scop global-attr-cashpays true
&scop host-attr-cashpays false
&scop shop-attr-cashpays false
&scop store-attr-cashpays false
&scop db-attr-cashpays false
&scop region-attr-cashpays false
&scop batch-edit-attr-cashpays  0
&scop level-way-attr-cashpays ",,global"
&scop up-way-attr-cashpays ",,cashpays"

/*бывший конф параметр cpgrpnam*/

/*Набор опций работы с документами МЦ*/
&scop label-attr-wthdoc "Набор опций работы c МЦ"
&scop tooltip-attr-wthdoc "Набор опций работы c МЦ"
&scop user-can-edit-attr-wthdoc true
&scop output-display-attr-wthdoc false
&scop other-attr-wthdoc 'spr-ext=adm\shattr33.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-wthdoc 'logical,logical'
&scop prop-label-list-attr-wthdoc '~
Закрывать документы при формировании по чекам МЦ~
,Проверка на наличие физ. лиц в документах МЦ '
&scop global-attr-wthdoc true
&scop host-attr-wthdoc false
&scop shop-attr-wthdoc false
&scop store-attr-wthdoc false
&scop db-attr-wthdoc false
&scop region-attr-wthdoc false
&scop batch-edit-attr-wthdoc  0
&scop level-way-attr-wthdoc ",,global"
&scop up-way-attr-wthdoc ",,wthdoc"


/*Набор опций работы с документами МЦ*/
&scop label-attr-wthdoc_obj "Набор опций работы с МЦ в контексте объекта"
&scop tooltip-attr-wthdoc_obj "Набор опций работы с МЦ в контексте объекта"
&scop user-can-edit-attr-wthdoc_obj true
&scop output-display-attr-wthdoc_obj false
&scop other-attr-wthdoc_obj 'spr-ext=adm\shattr25.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-wthdoc_obj 'character,integer,logical,logical,integer,integer,logical'
&scop prop-label-list-attr-wthdoc_obj '~
Префикс номера счета-фактуры~
,Правило автоматического установления срока годности партий серийных МЦ~
,Закрывать документы при формировании по чекам МЦ~
,При закрытии продажи автоматически формировать документ перемещения ~
,МХ формирования документов перемещени~
,Последний номер счет-фактуры~
,Проверка на наличие физ. лиц в документах МЦ'
&scop prop-list-attr-wthdoc_obj 'stfactpref,rangerule,clsfact,inobjauto,inwpcode,numsfact,prsdoc'
&scop global-attr-wthdoc_obj false
&scop host-attr-wthdoc_obj false
&scop shop-attr-wthdoc_obj true
&scop store-attr-wthdoc_obj true
&scop db-attr-wthdoc_obj false
&scop region-attr-wthdoc_obj false
&scop batch-edit-attr-wthdoc_obj  0
&scop attr-wthdoc_obj_stfactpref_tooltip stfactpref Префикс номера счета-фактуры при автоматической генерации номера в документах МЦ
&scop attr-wthdoc_obj_numsfact_tooltip   numsfact   Последний сгенерированный номер счет-фактуры
&scop attr-wthdoc_obj_rangerule_tooltip  rangerule  Срок годности устанавливается от даты счета-фактуры. Eсли счет-фактура не указан в документе` срок годности определяется от даты документа.
&scop attr-wthdoc_obj_clsfact_tooltip    clsfact    Автоматически закрывать до статуса Факт документы МЦ в режиме формирования документов по чекам МЦ (инкассация` кассовый фонд...)
&scop attr-wthdoc_obj_inobjauto_tooltip  inobjauto  Автоматическое формирование документов перемещения МЦ при закрытии продажи
&scop attr-wthdoc_obj_inwpcode_tooltip   inwpcode   МХ МЦ для документов перемещения` формируемых при закрытии продажи
&scop attr-wthdoc_obj_prsdoc_tooltip     prsdoc     При сохранении документа проверять корректно ли указаны ответственные лица
&scop prop-tooltip-list-attr-wthdoc_obj {&attr-wthdoc_obj_stfactpref_tooltip} , ~
{&attr-wthdoc_obj_rangerule_tooltip},~
{&attr-wthdoc_obj_clsfact_tooltip},~
{&attr-wthdoc_obj_inobjauto_tooltip},~
{&attr-wthdoc_obj_inwpcode_tooltip},~
{&attr-wthdoc_obj_numsfact_tooltip},~
{&attr-wthdoc_obj_prsdoc_tooltip}
&scop level-way-attr-wthdoc_obj "obj,,"
&scop up-way-attr-wthdoc_obj "wthdoc_obj,,"


/*Глобальные настройки для работы с МЦ*/
&scop type-attr-wthrep            {&type-char}
&scop format-attr-wthrep          "x(40)"
&scop label-attr-wthrep "Глобальные настройки для работы с МЦ"
&scop tooltip-attr-wthrep "Глобальные настройки для работы с МЦ"
&scop user-can-edit-attr-wthrep true
&scop output-display-attr-wthrep true
&scop other-attr-wthrep 'spr-ext=adm\shattr27.w':U
&scop prop-type-list-attr-wthrep 'character,logical':U
&scop prop-label-list-attr-wthrep 'Опции сводных отчетов по МЦ,Не передавать по СПН документы уничтожения и перемещения погашенных МЦ на УБД'
 &scop global-attr-wthrep true
&scop host-attr-wthrep false
&scop shop-attr-wthrep false
&scop store-attr-wthrep false
&scop db-attr-wthrep false
&scop region-attr-wthrep false
&scop batch-edit-attr-wthrep 0
&scop attr-wthrep_cligrplist_tooltip Список групп клиентов для формирования сводных отчетов
&scop prop-tooltip-list-attr-wthrep {&attr-wthrep_cligrplist_tooltip},Не передавать по СПН документы уничтожения и перемещения в зоне погашения на УБД
&scop level-way-attr-wthrep ",,global"
&scop up-way-attr-wthrep ",,attr-wthrep"


/*контекст для rum*/
&scop label-attr-rum "Машина правил (встраиваемые процедуры)"
&scop tooltip-attr-rum "Машина правил (настройка встраиваемых процедур)"
&scop user-can-edit-attr-rum true
&scop output-display-attr-rum false
&scop other-attr-rum 'spr-ext=adm\shattr26.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-rum 'logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical,logical'
&scop prop-label-list-attr-rum '~
Операции с товарами~
,Операции с клиентами~
,Операции с группами товаров~
,Операции с группами клиентов~
,Операции с чеками на POS IBS-TH~
,Операции с чеками на POS IBS-TH-MOB~
,Операции в системе электронного документооборота~
,Операции со справочниками~
,Операции с ДНЦ и переоценками~
,Отчеты~
,Операции с заказами~
,Комбинированные алгоритмы~
,Операции с фин.документами~
'
&scop global-attr-rum true
&scop host-attr-rum false
&scop shop-attr-rum false
&scop store-attr-rum false
&scop db-attr-rum false
&scop region-attr-rum false
&scop batch-edit-attr-rum  0
&scop manual-edit-attr-rum  '0,0,0,0,1,1,0,0,0,1,0,0,0,0'
&scop level-way-attr-rum ",,global"
&scop up-way-attr-rum ",,rum"
/**/

/*Контекст для rum_obj*/
&scop label-attr-rum_obj "Машина правил (встраиваемые процедуры) в контексте объекта"
&scop tooltip-attr-rum_obj "Машина правил (настройка встраиваемых процедур) в контексте объекта"
&scop user-can-edit-attr-rum_obj true
&scop output-display-attr-rum_obj false
&scop other-attr-rum_obj 'spr-ext=adm\shattr26.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-rum_obj 'logical,logical,logical'
&scop prop-label-list-attr-rum_obj '~
Операции с чеками на POS IBS-TH~
,Операции с чеками на POS IBS-TH-MOB~
,Отчеты~
'
&scop global-attr-rum_obj false
&scop host-attr-rum_obj false
&scop shop-attr-rum_obj true
&scop store-attr-rum_obj false
&scop db-attr-rum_obj false
&scop region-attr-rum_obj false
&scop batch-edit-attr-rum_obj  0
&scop manual-edit-attr-rum_obj  '1,1,1'
&scop level-way-attr-rum_obj "obj,,global"
&scop up-way-attr-rum_obj "rum_obj,,rum"

/**/


/* настройки easyfuel  */
&scop label-attr-easyfuel "Опции работы с системой EasyFuel"
&scop tooltip-attr-easyfuel "Опции работы с системой EasyFuel"
&scop user-can-edit-attr-easyfuel true
&scop output-display-attr-easyfuel false
&scop other-attr-easyfuel 'spr-ext=adm\shattr28.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-easyfuel 'character'
&scop prop-label-list-attr-easyfuel '~
Номер МАСТЕР-КЛЮЧА'
&scop global-attr-easyfuel false
&scop host-attr-easyfuel false
&scop shop-attr-easyfuel true
&scop store-attr-easyfuel false
&scop db-attr-easyfuel false
&scop region-attr-easyfuel false
&scop batch-edit-attr-easyfuel  0
&scop level-way-attr-easyfuel "obj,,"
&scop up-way-attr-easyfuel "easyfuel,,"

/**/
/* Параметры по Переоценкам  */
&scop type-attr-overval            {&type-char}
&scop format-attr-overval          "x(40)"
&scop label-attr-overval           "Настройки для ПЕРЕОЦЕНОК"
&scop tooltip-attr-overval         "Настройки для переоценок по объектам "
&scop user-can-edit-attr-overval   true
&scop output-display-attr-overval  true
&scop other-attr-overval           'spr-ext=gbl\overval.w':U
&scop prop-type-list-attr-overval  '~
logical,~
logical,~
logical,~
character,~
logical,~
logical,~
integer,~
decimal,~
character,~
logical,~
logical,~
logical,~
logical,~
decimal,~
character,~
logical,~
decimal,~
character,~
character,~
character,~
character~
':U
&scop prop-label-list-attr-overval '~
Удалять строки товаров`по которым нет остатков,~
Добавлять имеющиеся неосновные цены,~
Запрос при замене цены при добавлении,~
Исходная цена для вычисления отклонения торговой наценки,~
Запрос при добавлении строки как в другом приказе,~
Предупреждать об изменении скидки,~
Действие над товаром`цена на который не изменилась,~
Для поля Наценка,~
Возможные методы расчета цены,~
Сохранять спец. и основные цены,~
Добавлять имеющиеся цены партий,~
Вызов окна печати ценников при закрытии на акт авто.переоценки,~
Запрос при уменьшении текущей цены,~
Для поля База округления,~
Для поля Метод округления,~
Добавлять имеющиеся цены признаков,~
MAX допустимое отклонение цены без назначения новой,~
Запрет на виды товаров в ДНЦ в УБД,~
Запрет на виды товаров в ДНЦ в ГБД,~
Исключения из запретов в ДНЦ на УБД,~
Исключения из запретов в ДНЦ на ГБД~
'

&scop prop-list-attr-overval       '~
pr-abs-d,~
pr-altex,~
pr-clt-q,~
pr-discm,~
pr-dpl-q,~
pr-dscnt,~
pr-equ-dq,~
pr-incpc,~
pr-list,~
pr-notls,~
pr-parex,~
pr-print,~
pr-rdc-q,~
pr-rndbs,~
pr-rndmt,~
pr-sclex,~
pr-sigma,~
pr-goods,~
pr-goods0,~
pr-nogds,~
pr-nogds0~
'
&scop global-attr-overval true
&scop host-attr-overval true
&scop shop-attr-overval true
&scop store-attr-overval true
&scop db-attr-overval false
&scop region-attr-overval false
&scop batch-edit-attr-overval  0
&scop attr-overval_pr-abs-d_tooltip (pr-abs-d) При закрытии переоценки удалять строки` факт остаток товара по которым = 0 (главные цены удаляются только если нет специальных или неосновных)
&scop attr-overval_pr-altex_tooltip (pr-altex) При добавлении главной цены в переоценку автоматически добавлять строки для всех существующих в данных момент неосновных цен данного товара (в т.ч. на партии и признаки).
&scop attr-overval_pr-clt-q_tooltip (pr-clt-q) При добавлении строк в переоценку` если там уже есть строка для такого товара и цена в ней рассчитана` запрашивать` нужно ли ее переписывать новой (если новая не ?)
&scop attr-overval_pr-discm_tooltip (pr-discm) Используется для расчета отклонения новой продажной цены от указанной цены ( cost = среднеучетная по объекту ; sale = последняя приходная;  sale- = выбранная в интерфейсе переоценки или последняя приходная ; cost-vat = среднеучетная чистая ; prod = цена производителя ;prod-vat = цена производителя без НДС  )
&scop attr-overval_pr-dpl-q_tooltip (pr-dpl-q) При добавлении строк в переоценку` если есть строка для такого товара в другом приказе по этому же объекту` запрашивать подтвержение
&scop attr-overval_pr-dscnt_tooltip (pr-dscnt) При закрытии новой переоценки в статус приказ предупреждать в том случае` если хотя бы одна скидка (в неосновных ценах) была изменена
&scop attr-overval_pr-equ-dq_tooltip (pr-equ-dq) Выбор действия над строками главных цен` цена по которым не изменилась` если для них нет неосновных... Выбор действия над товаром. pr-equ-dq=1 - не удалять ; pr-equ-dq=2 - удалять с запросом ; pr-equ-dq=3 - удалять без запроса.
&scop attr-overval_pr-incpc_tooltip (pr-incpc) Значение поля Наценка в форме ТПЛ` которое подставляется при создании нового ТПЛ
&scop attr-overval_pr-list_tooltip  (pr-list)  Список используемых методов расчета цены в системе (Товар`Группа`УчетнаяS`Учетная`Учет-рзрвS`Учет-резерв`ПриходнаяS`Приходная`Старая`Новая`Объект`Накладная`Переоценка`ДокФормЦены`Накл-безНДС`Учет-НДСS`Учет-безНДС`Стар-безНДС`Учет+накл`Уч+накл-НДС`Единая`Отсутствует`Откат_цен`Не-считать`Производит`Произв-НДС`ПорогПр-НДС`ПорогПр+НДС`Спецификация)
&scop attr-overval_pr-notls_tooltip (pr-notls) Сохранять все цены. При добавлении главной цены в переоценку автоматически добавлять строки для всех существующих в спеццен (признаки` партии свободной зоны)` а также неосновные цены. При закрытии переоценки проверять` что ни одна из этих цен не была удалена.
&scop attr-overval_pr-parex_tooltip (pr-parex) При добавлении главной цены в переоценку автоматически добавлять строки для всех партий свободной зоны.
&scop attr-overval_pr-print_tooltip (pr-print) Автоматический вызов окна печати ценников при закрытии на акт автоматической переоценки
&scop attr-overval_pr-rdc-q_tooltip (pr-rdc-q) При закрытии переоценки запрашивать подтверждение каждый раз` когда встречается товар` цена на который снижена
&scop attr-overval_pr-rndbs_tooltip (pr-rndbs) Значение поля База округления`  которое подставляется при создании нового ТПЛ. Видно на экране и имеет смысл только при Способе округления 9-99-окончание` произвольно` вверх или коэффициент.
&scop attr-overval_pr-rndmt_tooltip (pr-rndmt) Значение поля Способ округления` которое подставляется при создании нового ТПЛ: pr-round-9end - 9-окончание` pr-round-9-99end - 9-99-окончание` pr-round-integer - без-дробных` pr-round-select - произвольно` pr-round-up - вверх` pr-round-coef - коэффициент` pr-round-off - отключено.
&scop attr-overval_pr-sclex_tooltip (pr-sclex) При добавлении главной цены в переоценку автоматически добавлять строки для всех существующих в данных момент цен на признаки.
&scop attr-overval_pr-sigma_tooltip (pr-sigma) Максимально допустимое отклонение рассчитываемой в переоценке цены от текущей цены продажи товара (в процентах)` в пределах которого не происходит назначение новой цены продажи товара
&scop attr-overval_pr-goods_tooltip (pr-goods) Запрет на определенные виды товаров в ДНЦ в УБД
&scop attr-overval_pr-goods0_tooltip (pr-goods0) Запрет на определенные виды товаров в ДНЦ в ГБД
&scop attr-overval_pr-nogds_tooltip (pr-nogds) Исключения из Запретов по pr-goods на группы товаров в ДНЦ на активных объектах в УБД. Указанные группы разрешены к включению в ДНЦ . Можно указывать нетерминальные группы. При указании головной группы ТОВАРЫ - предыдущие запреты  снимаются - ДНЦ сделать можно на все товары.~
При указании пусто или 0 - исключений нет и действуют только запреты указанные в параметре ЗАПРЕТ НА ОПРЕДЕЛЕННЫЕ ВИДЫ ТОВАРОВ (pr-goods)
&scop attr-overval_pr-nogds0_tooltip (pr-nogds0) Исключения из Запретов по pr-goods на группы товаров в ДНЦ на ГБД. Указанные группы разрешены к включению в ДНЦ . Можно указывать нетерминальные группы. При указании головной группы ТОВАРЫ - предыдущие запреты  снимаются - ДНЦ сделать можно на все товары.~
При указании пусто или 0 - исключений нет и действуют только запреты указанные в параметре ЗАПРЕТ НА ОПРЕДЕЛЕННЫЕ ВИДЫ ТОВАРОВ (pr-goods)

&scop prop-tooltip-list-attr-overval {&attr-overval_pr-abs-d_tooltip},~
{&attr-overval_pr-altex_tooltip},~
{&attr-overval_pr-clt-q_tooltip},~
{&attr-overval_pr-discm_tooltip},~
{&attr-overval_pr-dpl-q_tooltip},~
{&attr-overval_pr-dscnt_tooltip},~
{&attr-overval_pr-equ-dq_tooltip},~
{&attr-overval_pr-incpc_tooltip},~
{&attr-overval_pr-list_tooltip},~
{&attr-overval_pr-notls_tooltip},~
{&attr-overval_pr-parex_tooltip},~
{&attr-overval_pr-print_tooltip},~
{&attr-overval_pr-rdc-q_tooltip},~
{&attr-overval_pr-rndbs_tooltip},~
{&attr-overval_pr-rndmt_tooltip},~
{&attr-overval_pr-sclex_tooltip},~
{&attr-overval_pr-sigma_tooltip},~
{&attr-overval_pr-goods_tooltip},~
{&attr-overval_pr-goods0_tooltip},~
{&attr-overval_pr-nogds_tooltip},~
{&attr-overval_pr-nogds0_tooltip}
&scop level-way-attr-overval "obj,host,global"
&scop up-way-attr-overval "overval,overval,overval"



/*pos ibs-th*/
&scop label-attr-cd-type-ibs-th "Настройки и опции работы POS IBS TH"
&scop tooltip-attr-cd-type-ibs-th "Настройки и опции работы POS IBS TH"
&scop user-can-edit-attr-cd-type-ibs-th true
&scop output-display-attr-cd-type-ibs-th false
&scop other-attr-cd-type-ibs-th 'spr-ext=adm\shattr29.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-ibs-th 'void,void,void,void,void'
&scop prop-label-list-attr-cd-type-ibs-th '~
Основные настройки~
,Работа с устройствами~
,Настройки для ФР~
,Настройки чеков~
,Интерфейс~
'
&scop global-attr-cd-type-ibs-th true
&scop host-attr-cd-type-ibs-th false
&scop shop-attr-cd-type-ibs-th true
&scop store-attr-cd-type-ibs-th false
&scop db-attr-cd-type-ibs-th false
&scop region-attr-cd-type-ibs-th false
&scop batch-edit-attr-cd-type-ibs-th  0
&scop level-way-attr-cd-type-ibs-th "obj,,global"
&scop up-way-attr-cd-type-ibs-th "cd-type-ibs-th,,cd-type-ibs-th"



&scop label-attr-cd-type-ibs-th_ibs-th_main "Основные настройки и опции"
&scop tooltip-attr-cd-type-ibs-th_ibs-th_main "Основные настройки и опции работы POS IBS TH"
&scop user-can-edit-attr-cd-type-ibs-th_ibs-th_main true
&scop output-display-attr-cd-type-ibs-th_ibs-th_main false
&scop other-attr-cd-type-ibs-th_ibs-th_main 'init-ext=adm\shattri.p/copy-2cda=yes':U
&scop prop-type-list-attr-cd-type-ibs-th_ibs-th_main 'integer,integer,integer,integer,integer,integer,integer'
&scop prop-label-list-attr-cd-type-ibs-th_ibs-th_main '~
Работа со сменами~
,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1)~
,Обязателен продавец~
,Разрешена ручная скидка~
,Уровень логирования~
,Обнулять счетчик наличности при Z-отчете~
,Разрешена коррекция кол-ва~
'
&scop global-attr-cd-type-ibs-th_ibs-th_main true
&scop host-attr-cd-type-ibs-th_ibs-th_main false
&scop shop-attr-cd-type-ibs-th_ibs-th_main true
&scop store-attr-cd-type-ibs-th_ibs-th_main false
&scop db-attr-cd-type-ibs-th_ibs-th_main false
&scop region-attr-cd-type-ibs-th_ibs-th_main false
&scop batch-edit-attr-cd-type-ibs-th_ibs-th_main  0
&scop level-way-attr-cd-type-ibs-th_ibs-th_main "obj,,global"
&scop up-way-attr-cd-type-ibs-th_ibs-th_main "ibs-th_main,,ibs-th_main"



&scop label-attr-cd-type-ibs-th_ibs-th_devices "Работа с устройствами"
&scop tooltip-attr-cd-type-ibs-th_ibs-th_devices "Работа с устройствами POS IBS TH"
&scop user-can-edit-attr-cd-type-ibs-th_ibs-th_devices true
&scop output-display-attr-cd-type-ibs-th_ibs-th_devices false
&scop other-attr-cd-type-ibs-th_ibs-th_devices 'init-ext=adm\shattri.p/copy-2cda=yes':U
&scop prop-type-list-attr-cd-type-ibs-th_ibs-th_devices 'integer,integer,integer,integer,integer,decimal,integer,integer,character,character,character,character,character,character,character,character'
&scop prop-label-list-attr-cd-type-ibs-th_ibs-th_devices '~
Подключать ДЯ~
,Тип подключения ДЯ~
,Порт подключения ДЯ~
,Кол-во имп. подключения ДЯ~
,Работа с открытым ДЯ~
,Предел наличности ДЯ~
,Подключать кардридер~
,Подключать дисплей покупателя~
,Текст рекламы на дисплее покупателя~
,Тип клавиатуры~
,Раскладка клавиатуры~
,Система безналичных платежей~
,Тип дисплея покупателя~
,Порт дисплея покупателя~
,Тип системы видеонаблюдения~
,Адрес/порт системы видеонаблюдения~
'
&scop global-attr-cd-type-ibs-th_ibs-th_devices true
&scop host-attr-cd-type-ibs-th_ibs-th_devices false
&scop shop-attr-cd-type-ibs-th_ibs-th_devices true
&scop store-attr-cd-type-ibs-th_ibs-th_devices false
&scop db-attr-cd-type-ibs-th_ibs-th_devices false
&scop region-attr-cd-type-ibs-th_ibs-th_devices false
&scop batch-edit-attr-cd-type-ibs-th_ibs-th_devices  0
&scop level-way-attr-cd-type-ibs-th_ibs-th_devices "obj,,global"
&scop up-way-attr-cd-type-ibs-th_ibs-th_devices "ibs-th_devices,,ibs-th_devices"


&scop label-attr-cd-type-ibs-th_ibs-th_fisreg "Настройки для ФР"
&scop tooltip-attr-cd-type-ibs-th_ibs-th_fisreg "Настройки для ФР POS IBS TH"
&scop user-can-edit-attr-cd-type-ibs-th_ibs-th_fisreg true
&scop output-display-attr-cd-type-ibs-th_ibs-th_fisreg false
&scop other-attr-cd-type-ibs-th_ibs-th_fisreg 'init-ext=adm\shattri.p/copy-2cda=yes':U
&scop prop-type-list-attr-cd-type-ibs-th_ibs-th_fisreg 'integer,character,character,integer,character'
&scop prop-label-list-attr-cd-type-ibs-th_ibs-th_fisreg '~
Логический уровень датчика ДЯ в открытом состоянии~
,Типы кассовых платежей TH<->коды оплаты ФР~
,Наименования типов оплат ФР~
,Отрезание чеков~
,ФР подключен к~
'
&scop global-attr-cd-type-ibs-th_ibs-th_fisreg true
&scop host-attr-cd-type-ibs-th_ibs-th_fisreg false
&scop shop-attr-cd-type-ibs-th_ibs-th_fisreg true
&scop store-attr-cd-type-ibs-th_ibs-th_fisreg false
&scop db-attr-cd-type-ibs-th_ibs-th_fisreg false
&scop region-attr-cd-type-ibs-th_ibs-th_fisreg false
&scop batch-edit-attr-cd-type-ibs-th_ibs-th_fisreg  0
&scop level-way-attr-cd-type-ibs-th_ibs-th_fisreg "obj,,global"
&scop up-way-attr-cd-type-ibs-th_ibs-th_fisreg "ibs-th_fisreg,,ibs-th_fisreg"


&scop label-attr-cd-type-ibs-th_ibs-th_rec-print "Настройки для чеков"
&scop tooltip-attr-cd-type-ibs-th_ibs-th_rec-print "Настройки для чеков POS IBS TH"
&scop user-can-edit-attr-cd-type-ibs-th_ibs-th_rec-print true
&scop output-display-attr-cd-type-ibs-th_ibs-th_rec-print false
&scop other-attr-cd-type-ibs-th_ibs-th_rec-print 'init-ext=adm\shattri.p/copy-2cda=yes':U
&scop prop-type-list-attr-cd-type-ibs-th_ibs-th_rec-print 'decimal,character,character,integer,character,decimal,integer,integer'
&scop prop-label-list-attr-cd-type-ibs-th_ibs-th_rec-print '~
Макс.сумма чека~
,Рекламный текст~
,Строки клише~
,Печатать код товара~
,Тип округления суммы чека~
,Коэфф. типа округления суммы чека~
,Печатать слип отлож.чека~
,Печатать отлож.чек на доп.принтере~
'
&scop global-attr-cd-type-ibs-th_ibs-th_rec-print true
&scop host-attr-cd-type-ibs-th_ibs-th_rec-print false
&scop shop-attr-cd-type-ibs-th_ibs-th_rec-print true
&scop store-attr-cd-type-ibs-th_ibs-th_rec-print false
&scop db-attr-cd-type-ibs-th_ibs-th_rec-print false
&scop region-attr-cd-type-ibs-th_ibs-th_rec-print false
&scop batch-edit-attr-cd-type-ibs-th_ibs-th_rec-print  0
&scop level-way-attr-cd-type-ibs-th_ibs-th_rec-print "obj,,global"
&scop up-way-attr-cd-type-ibs-th_ibs-th_rec-print "ibs-th_rec-print,,ibs-th_rec-print"


&scop label-attr-cd-type-ibs-th_ibs-th_interface "Настройки интерфейса"
&scop tooltip-attr-cd-type-ibs-th_ibs-th_interface "Настройки интерфейса POS IBS TH"
&scop user-can-edit-attr-cd-type-ibs-th_ibs-th_interface true
&scop output-display-attr-cd-type-ibs-th_ibs-th_interface false
&scop other-attr-cd-type-ibs-th_ibs-th_interface 'init-ext=adm\shattri.p/copy-2cda=yes':U
&scop prop-type-list-attr-cd-type-ibs-th_ibs-th_interface 'character,character'
&scop prop-label-list-attr-cd-type-ibs-th_ibs-th_interface '~
Вид интерфейса~
,Раскладка~
'
&scop global-attr-cd-type-ibs-th_ibs-th_interface true
&scop host-attr-cd-type-ibs-th_ibs-th_interface false
&scop shop-attr-cd-type-ibs-th_ibs-th_interface true
&scop store-attr-cd-type-ibs-th_ibs-th_interface false
&scop db-attr-cd-type-ibs-th_ibs-th_interface false
&scop region-attr-cd-type-ibs-th_ibs-th_interface false
&scop batch-edit-attr-cd-type-ibs-th_ibs-th_interface  0
&scop level-way-attr-cd-type-ibs-th_ibs-th_interface "obj,,global"
&scop up-way-attr-cd-type-ibs-th_ibs-th_interface "ibs-th_interface,,ibs-th_interface"


/*pos ibs-th-mob*/
&scop label-attr-cd-type-ibs-th-mob "Настройки и опции работы POS IBS TH-MOB"
&scop tooltip-attr-cd-type-ibs-th-mob "Настройки и опции работы POS IBS TH-MOB"
&scop user-can-edit-attr-cd-type-ibs-th-mob true
&scop output-display-attr-cd-type-ibs-th-mob false
&scop other-attr-cd-type-ibs-th-mob 'spr-ext=adm\shattr31.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-cd-type-ibs-th-mob 'void,void'
&scop prop-label-list-attr-cd-type-ibs-th-mob '~
Основные настройки~
'
&scop global-attr-cd-type-ibs-th-mob true
&scop host-attr-cd-type-ibs-th-mob false
&scop shop-attr-cd-type-ibs-th-mob true
&scop store-attr-cd-type-ibs-th-mob false
&scop db-attr-cd-type-ibs-th-mob false
&scop region-attr-cd-type-ibs-th-mob false
&scop batch-edit-attr-cd-type-ibs-th-mob  0
&scop level-way-attr-cd-type-ibs-th-mob "obj,,global"
&scop up-way-attr-cd-type-ibs-th-mob "cd-type-ibs-th-mob,,cd-type-ibs-th-mob"


&scop label-attr-cd-type-ibs-th-mob_ibs-th-mob_main "Основные настройки и опции"
&scop tooltip-attr-cd-type-ibs-th-mob_ibs-th-mob_main "Основные настройки и опции работы POS IBS TH-MOB"
&scop user-can-edit-attr-cd-type-ibs-th-mob_ibs-th-mob_main true
&scop output-display-attr-cd-type-ibs-th-mob_ibs-th-mob_main false
&scop other-attr-cd-type-ibs-th-mob_ibs-th-mob_main 'init-ext=adm\shattri.p/copy-2cda=yes':U
&scop prop-type-list-attr-cd-type-ibs-th-mob_ibs-th-mob_main 'integer,character'
&scop prop-label-list-attr-cd-type-ibs-th-mob_ibs-th-mob_main '~
,Обязателен продавец~
,Тип кассы, которого брать скидки~
'
&scop global-attr-cd-type-ibs-th-mob_ibs-th-mob_main true
&scop host-attr-cd-type-ibs-th-mob_ibs-th-mob_main false
&scop shop-attr-cd-type-ibs-th-mob_ibs-th-mob_main true
&scop store-attr-cd-type-ibs-th-mob_ibs-th-mob_main false
&scop db-attr-cd-type-ibs-th-mob_ibs-th-mob_main false
&scop region-attr-cd-type-ibs-th-mob_ibs-th-mob_main false
&scop batch-edit-attr-cd-type-ibs-th-mob_ibs-th-mob_main  0
&scop level-way-attr-cd-type-ibs-th-mob_ibs-th-mob_main "obj,,global"
&scop up-way-attr-cd-type-ibs-th-mob_ibs-th-mob_main "ibs-th-mob_main,,ibs-th-mob_main"


&scop label-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print "Настройки для чеков"
&scop tooltip-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print "Настройки для чеков POS IBS TH-MOB"
&scop user-can-edit-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print true
&scop output-display-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print false
&scop other-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print 'init-ext=adm\shattri.p/copy-2cda=yes':U
&scop prop-type-list-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print 'integer,integer'
&scop prop-label-list-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print '~
Печатать слип отлож.чека~
,Печатать отлож.чек на доп.принтере~
'
&scop global-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print true
&scop host-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print false
&scop shop-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print true
&scop store-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print false
&scop db-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print false
&scop region-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print false
&scop batch-edit-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print  0
&scop level-way-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print "obj,,global"
&scop up-way-attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print "ibs-th-mob_rec-print,,ibs-th-mob_rec-print"



/* Общие параметры по ИНВЕНТАРИЗАЦИИ */
&scop type-attr-inv-global            {&type-char}
&scop format-attr-inv-global          "x(40)"
&scop label-attr-inv-global           "Настройки для ИНВЕНТАРИЗАЦИИ глобально"
&scop tooltip-attr-inv-global         "Настройки для ИНВЕНТАРИЗАЦИИ global"
&scop user-can-edit-attr-inv-global   true
&scop output-display-attr-inv-global  true
&scop other-attr-inv-global           'spr-ext=gbl\inventpa.w':U
&scop prop-type-list-attr-inv-global  'logical,logical,integer':U
&scop prop-label-list-attr-inv-global '~
Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ДОПОЛНИТЕЛЬНЫЕ СУММЫ ON-LINE в документы инвентаризации,~
Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ЕСТЕСТВЕННУЮ УБЫЛЬ ON-LINE в документе инвентаризации,~
Причина заведения документа для инвентаризации использующейся как документ пересортицы'
&scop prop-list-attr-inv-global       'invclcas,invclcwt,inv-prs'
&scop global-attr-inv-global true
&scop host-attr-inv-global false
&scop shop-attr-inv-global false
&scop store-attr-inv-global false
&scop db-attr-inv-global false
&scop region-attr-inv-global false
&scop batch-edit-attr-inv-global  0
&scop attr-inv-global-invclcas_tooltip (invclcas) Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ДОПОЛНИТЕЛЬНЫЕ СУММЫ ON-LINE в документы инвентаризации
&scop attr-inv-global-invclcwt_tooltip (invclcwt) Начальная установка атрибута ПЕРЕСЧИТЫВАТЬ ЕСТЕСТВЕННУЮ УБЫЛЬ ON-LINE в документе инвентаризации
&scop attr-inv-global-inv-prs_tooltip (inv-prs) Причина заведения документа для инвентаризации использующейся как документ пересортицы
&scop prop-tooltip-list-attr-inv-global {&attr-inv-global-invclcas_tooltip},{&attr-inv-global-invclcwt_tooltip},{&attr-inv-global-inv-prs_tooltip}
&scop level-way-attr-inv-global ",,global"
&scop up-way-attr-inv-global ",,inv-global"


/* параметры по ИНВЕНТАРИЗАЦИИ по объектам */
&scop type-attr-inv-obj            {&type-char}
&scop format-attr-inv-obj          "x(40)"
&scop label-attr-inv-obj           "Настройки для ИНВЕНТАРИЗАЦИИ"
&scop tooltip-attr-inv-obj         "Настройки для ИНВЕНТАРИЗАЦИИ по объектам"
&scop user-can-edit-attr-inv-obj   true
&scop output-display-attr-inv-obj  true
&scop other-attr-inv-obj           'spr-ext=gbl\inventpa.w':U
&scop prop-type-list-attr-inv-obj  '~
logical,~
logical,~
decimal,~
decimal,~
decimal,~
decimal,~
logical,~
logical,~
logical,~
logical,~
logical,~
logical,~
logical~
':U
&scop prop-label-list-attr-inv-obj '~
Рассчитывать суммы в единицах поставщика,~
Удаление нулевых строк в инвентаризации,~
Максимальное процентное отклонение уменьшения цены в документе пересортица,~
Максимальное процентное отклонение увеличения цены в документе пересортица,~
Максимальное абсолютное отклонение уменьшения цены в документе пересортица,~
Максимальное абсолютное отклонение увеличения цены в документе пересортица,~
Возможность пересортицы товаров с одной единицей измерения в разных количествах,~
Начисление естественной убыли,~
Запрещена пересортица товаров из разных групп,~
Запрещена пересортица товаров с разными единицами измерения,~
Приходовать излишки по продажным ценам без НДС,~
Разрешить создание инвентаризации с отрицательными количествами'
&scop prop-list-attr-inv-obj  'invclcsp,invdnull,mxpcdcp,mxpcicp,mxsmdcp,mxsmicp,pstunqtn,wastage,pstgrp,pstunit,izlcstpr,minus'
&scop global-attr-inv-obj true
&scop host-attr-inv-obj true
&scop shop-attr-inv-obj true
&scop store-attr-inv-obj true
&scop db-attr-inv-obj false
&scop region-attr-inv-obj false
&scop batch-edit-attr-inv-obj  0
&scop attr-inv-obj-invclcsp_tooltip  (invclcsp) УСТАНОВКА В YES ЗАМЕДЛЯЕТ РАСЧЕТ ИНВЕНТАРИЗАЦИИ В ДВА РАЗА. Реально нужен только для отдела ЦУМа для обсчета золота
&scop attr-inv-obj-invdnull_tooltip  (invdnull) Удаление нулевых строк (с количествами <было> и <стало> равными 0) в документе инвентаризации в момент закрытия документа до статуса <факт> (для сокращения объемов документа инвентаризации)
&scop attr-inv-obj-mxpcdcp_tooltip   (mxpcdcp) Максимальное процентное отклонение уменьшения цены в документе пересортица
&scop attr-inv-obj-mxpcicp_tooltip   (mxpcicp) Максимальное процентное отклонение увеличения цены в документе пересортица
&scop attr-inv-obj-mxsmdcp_tooltip   (mxsmdcp) Максимальное абсолютное отклонение уменьшения цены в документе пересортица
&scop attr-inv-obj-mxsmicp_tooltip   (mxsmicp) Максимальное абсолютное отклонение увеличения цены в документе пересортица
&scop attr-inv-obj-pstunqtn_tooltip  (pstunqtn) Возможность пересортицы товаров с одной единицей измерения в разных количествах
&scop attr-inv-obj-wastage_tooltip   (wastage) Начисление естественной убыли
&scop attr-inv-obj-pstgrp_tooltip  (pstgrp) Установка Yes запрещает добавлять товары из разных групп
&scop attr-inv-obj-pstunit_tooltip  (pstunit) Установка Yes запрещает добавлять товары с разными единицами измерения
&scop attr-inv-obj-izlcstpr_tooltip  (izlcstpr) Yes - излишки в инвентаризации приходуются по продажным ценам без НДС
&scop attr-inv-obj-minus_tooltip  (nominus) Yes - Разрешить создание инвентаризации с отрицательными количествами
&scop prop-tooltip-list-attr-inv-obj {&attr-inv-obj-invclcsp_tooltip},{&attr-inv-obj-invdnull_tooltip},{&attr-inv-obj-mxpcdcp_tooltip},{&attr-inv-obj-mxpcicp_tooltip},{&attr-inv-obj-mxsmdcp_tooltip},{&attr-inv-obj-mxsmicp_tooltip},{&attr-inv-obj-pstunqtn_tooltip},{&attr-inv-obj-wastage_tooltip},{&attr-inv-obj-pstgrp_tooltip},{&attr-inv-obj-pstunit_tooltip},{&attr-inv-obj-izlcstpr_tooltip},{&attr-inv-obj-nominus_tooltip}
&scop level-way-attr-inv-obj "obj,host,global"
&scop up-way-attr-inv-obj "inv-obj,inv-obj,inv-obj"

/* Сервер авторизации АСУ */
&scop label-attr-srv-auth-ASU           "Сервер авторизации АСУ"
&scop tooltip-attr-srv-auth-ASU         "Сервер авторизации АСУ"
&scop user-can-edit-attr-srv-auth-ASU   true
&scop output-display-attr-srv-auth-ASU  true
&scop other-attr-srv-auth-ASU 'spr-ext=adm\shattrsa.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-srv-auth-ASU 'character,character':U
&scop prop-label-list-attr-srv-auth-ASU 'Код контрагента РКО обязательного к авторизации,~
Адрес сервера авторизации ~
'
&scop global-attr-srv-auth-ASU true
&scop host-attr-srv-auth-ASU true
&scop shop-attr-srv-auth-ASU true
&scop store-attr-srv-auth-ASU true
&scop db-attr-srv-auth-ASU false
&scop region-attr-srv-auth-ASU false
&scop batch-edit-attr-srv-auth-ASU  0
&scop level-way-attr-srv-auth-ASU "obj,host,global"
&scop up-way-attr-srv-auth-ASU "srv-auth-ASU,srv-auth-ASU,srv-auth-ASU"
/* pko-cli,srv-auth-adr */

/* Настройки для обмена с ЕГАИС */
&scop type-attr-egais-host            {&type-char}
&scop format-attr-egais-host          "x(40)"
&scop label-attr-egais-host           "Настройки для обмена с ЕГАИС"
&scop tooltip-attr-egais-host         "Настройки для обмена с ЕГАИС"
&scop user-can-edit-attr-egais-host   true
&scop output-display-attr-egais-host  true
&scop other-attr-egais-host           'spr-ext=gbl\exegais.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-egais-host  'character,character,character,character,integer':U
&scop prop-label-list-attr-egais-host 'Код ФСРАР,Адрес УТМ,Версия XSD схем,ИНН фирмы,Номер внешней системы'
&scop prop-list-attr-egais-host       'egais-fsrar,egais-utm,egais-ver-xsd,egais-inn,egais-exsys'
&scop global-attr-egais-host true
&scop host-attr-egais-host false
&scop shop-attr-egais-host true
&scop store-attr-egais-host true
&scop db-attr-egais-host false
&scop region-attr-egais-host false
/*&scop batch-edit-attr-egais-host  0*/
&scop level-way-attr-egais-host "obj,,global"
&scop up-way-attr-egais-host "egais,egais,egais,egais,egais"

/* Настройки для подключения к ГИС МТ и проверки КМ */
&scop type-attr-gisMT            {&type-char}
&scop format-attr-gisMT          "x(40)"
&scop label-attr-gisMT           "Настройки для подключения к ГИС МТ и проверки КМ"
&scop tooltip-attr-gisMT         "Настройки для подключения к ГИС МТ и проверки КМ"
&scop user-can-edit-attr-gisMT   true
&scop output-display-attr-gisMT  true
&scop other-attr-gisMT           'spr-ext=gbl\gis.w':U
&scop prop-type-list-attr-gisMT  'character,character,character,character,character,integer,character,integer,decimal,logical,integer,logical,character,logical,logical,integer,logical,~
character,character,character,decimal,integer,character,character,character,decimal,character,integer':U
&scop prop-label-list-attr-gisMT 'Адрес и порт проски-сервера,Дополнительные параметры запроса,Адрес ГИС МТ,Логин,Пароль,Макс.допуст. время разрешения продажи при сбое,ключ авторизации,~
Время с момента сбоя до начала уведомления персонала,Длительность ожидания ответа ГИС МТ,Аварийная ситуация в ГИС МТ,Опережение срабатывания запрета по сроку годности в минутах,~
Работа с cdn-площадками,Адрес cdn,Повторный опрос площадки,Смена площадки,Период обновления списка CDN-площадок,Обновление параметров при запросе КМ,Адрес ЛМ ЧЗ,Логин в ЛМ ЧЗ,Пароль в ЛМ ЧЗ,~
Время ожидания ответа ТН,Обязательность получения результатов проверки КМ в ТН,Порт для отправки запроса проверки марки в ЛМ ЧЗ,Адрес для отправки запроса проверки марки в ТН,~
Порт для отправки запроса проверки марки в ТН,Длительность обработки ответа ГИС МТ в ТС ПИоТ,Токен авторизации MAX,Проверка возраста при продаже НП'
&scop prop-list-attr-gisMT       'adressPort,dopParam,gisAdress,proxyLogin,proxyPswd,maxTime,regKey,timeFalStart,waitTime,crashSituat,banDate,cdnTurnOn,cdnAdress,cdnRepeat,cdnChange,cdnTimeUpdate,~
UpdateRequest,OflineAdress,OflineLogin,OflinePswd,MACC_Timeout,Resp_TH_required,LmCHzPort,TH_IP,TH_Port,AddTimeoutPIoT,MaxApiToken,AgeConfirm'
&scop global-attr-gisMT true
&scop host-attr-gisMT false
&scop shop-attr-gisMT false
&scop store-attr-gisMT false
&scop db-attr-gisMT true
&scop region-attr-gisMT true
&scop level-way-attr-gisMT "db,region,global"
&scop up-way-attr-gisMT "gisMT,gisMT,gisMT"

/* Общие параметры по АРХИВАМ */
&scop type-attr-arh-global            {&type-char}
&scop format-attr-arh-global          "x(40)"
&scop label-attr-arh-global           "Настройки для Архивов"
&scop tooltip-attr-arh-global         "Настройки для Архивов глобально"
&scop user-can-edit-attr-arh-global   true
&scop output-display-attr-arh-global  true
&scop other-attr-arh-global           'spr-ext=gbl\arhglpa.w':U
&scop prop-type-list-attr-arh-global  'logical,character':U
&scop prop-label-list-attr-arh-global '~
Автоматический запуск расчета архивов после приема новостей,~
Список отложенных заданий которые надо пропустить'
&scop prop-list-attr-arh-global       'apusharh,btprskip'
&scop global-attr-arh-global true
&scop host-attr-arh-global false
&scop shop-attr-arh-global false
&scop store-attr-arh-global false
&scop db-attr-arh-global false
&scop region-attr-arh-global false
&scop batch-edit-attr-arh-global  0
&scop attr-arh-global-apusharh_tooltip (apusharh) Автоматический запуск расчета арховов после приема новостей
&scop attr-arh-global-btprskip_tooltip (btprskip) Заблокировать выполнение некоторых типов отложенных заданий. Типы необходимо перечислить через запятую. Возможные типы: trntx - расчет trn-tax` trnhd - расчет шапки документов` arh - расчет архивов
&scop prop-tooltip-list-attr-arh-global {&attr-arh-global-apusharh_tooltip},{&attr-arh-global-btprskip_tooltip}
&scop level-way-attr-arh-global ",,global"
&scop up-way-attr-arh-global ",,arh-global"


/* Общие параметры по РЕЗЕРВИРОВАНИЮ */
&scop type-attr-rezerv-global            {&type-char}
&scop format-attr-rezerv-global          "x(40)"
&scop label-attr-rezerv-global           "Настройки для РЕЗЕРВИРОВАНИЯ глобально"
&scop tooltip-attr-rezerv-global         "Настройки для РЕЗЕРВИРОВАНИЯ глобально"
&scop user-can-edit-attr-rezerv-global   true
&scop output-display-attr-rezerv-global  true
&scop other-attr-rezerv-global           'spr-ext=gbl\rezervpa.w':U
&scop prop-type-list-attr-rezerv-global  'logical':U
&scop prop-label-list-attr-rezerv-global 'Создавать ли бар-коды партий'
&scop prop-list-attr-rezerv-global       'parts-bc'
&scop global-attr-rezerv-global true
&scop host-attr-rezerv-global false
&scop shop-attr-rezerv-global false
&scop store-attr-rezerv-global false
&scop db-attr-rezerv-global false
&scop region-attr-rezerv-global false
&scop batch-edit-attr-rezerv-global  0
&scop attr-rezerv-global-parts-bc_tooltip (parts-bc) Глобальный. При закрытии накладной в статус накл+ на партии создается бар-код
&scop prop-tooltip-list-attr-rezerv-global {&attr-rezerv-global-parts-bc_tooltip},
&scop level-way-attr-rezerv-global ",,global"
&scop up-way-attr-rezerv-global ",,rezerv-global"


/* параметры по РЕЗЕРВИРОВАНИЮ по объектам */
&scop type-attr-rezerv-obj            {&type-char}
&scop format-attr-rezerv-obj          "x(40)"
&scop label-attr-rezerv-obj           "Настройки для РЕЗЕРВИРОВАНИЯ"
&scop tooltip-attr-rezerv-obj         "Настройки для РЕЗЕРВИРОВАНИЯ по объектам"
&scop user-can-edit-attr-rezerv-obj   true
&scop output-display-attr-rezerv-obj  true
&scop other-attr-rezerv-obj           'spr-ext=gbl\rezervpa.w':U
&scop prop-type-list-attr-rezerv-obj  '~
date,~
date,~
character,~
character,~
logical,~
character,~
character,~
logical,~
character,~
character,~
logical~
':U

&scop prop-label-list-attr-rezerv-obj '~
Диапазон для резервирования отрицательных партии по <-Партии>,~
-,~
Запрещается порождение отрицательных партий в производстве,~
Запрещается порождение отрицательных партий во всех документах (дальнейший анализ не производится),~
Допускается закрытие порожденных партий с учетной ценой 0 в документах продажи` возврата в магазине,~
Действие при созд порожд партии для док расх-возв продажи в маг-не с 0 учет цен,~
Действие при созд порожд партии по док-ту расх-возвр прод в маг-не с уч цен <> 0,~
Допускается закрытие порожденных партий с учетной ценой 0 во всех документах` кроме расхода` возврата продажи в магазине,~
При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с 0 уч цен,~
При порожд партии для всех док-ов кроме расх-возвр прод в маг-не с уч цен <> 0,~
Для порожд партий без закуп цены взять цену по розничной цене без НДС (TRN125)'

&scop prop-list-attr-rezerv-obj  'invngbeg,invngend,negmanuf,negparts,prcshfc0,prcshrs0,prcshrs1,prdocfc0,prdocrs0,prdocrs1,prsalpr'
&scop global-attr-rezerv-obj true
&scop host-attr-rezerv-obj true
&scop shop-attr-rezerv-obj true
&scop store-attr-rezerv-obj true
&scop db-attr-rezerv-obj false
&scop region-attr-rezerv-obj false
&scop batch-edit-attr-rezerv-obj  0
&scop attr-rezerv-obj-invngbeg_tooltip   (invngbeg) Начало диапазона для резервирования отрицательных партии по функции -Партии
&scop attr-rezerv-obj-invngend_tooltip   (invngend) Конец диапазона для резервирования отрицательных партии по функции -Партии
&scop attr-rezerv-obj-negmanuf_tooltip   (negmanuf) При указании значения disable запрещается порождение отрицательных партий в производстве
&scop attr-rezerv-obj-negparts_tooltip   (negparts) При указании значения disable запрещается порождение отрицательных партий во всех документах (дальнейший анализ не производится)
&scop attr-rezerv-obj-prcshfc0_tooltip   (prcshfc0) Допускается закрытие порожденных партий с учетной ценой 0 в документах продажи` возврата в магазине
&scop attr-rezerv-obj-prcshrs0_tooltip   (prcshrs0) Действие при созд порожд партии для док расх-возв продажи в маг-не с 0 учет цен    disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий
&scop attr-rezerv-obj-prcshrs1_tooltip   (prcshrs1) Действие при созд порожд партии по док-ту расх-возвр прод в маг-не с уч цен <> 0   disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий
&scop attr-rezerv-obj-prdocfc0_tooltip   (prdocfc0) Допускается закрытие порожденных партий с учетной ценой 0 во всех документах` кроме расхода`. возврата продажи в магазине
&scop attr-rezerv-obj-prdocrs0_tooltip   (prdocrs0) при порожд партии для всех док-ов кроме расх-возвр прод в маг-не с 0 уч цен    disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий
&scop attr-rezerv-obj-prdocrs1_tooltip   (prdocrs1) при порожд партии для всех док-ов кроме расх-возвр прод в маг-не с уч цен <> 0  disable - партии не создаются` enable - партии создаются без подтверждения` prompt - выводится диалог подтверждения цены` manual - выводится диалог редактирования партий
&scop attr-rezerv-obj-prsalpr_tooltip    (prsalpr)  Для порожд.партий без закуп.цены взять цену по розничной цене без НДС (TRN125) Производить порождение отрицательных партий в случае отсутствия закупочной цены по розничной цене без НДС
&scop prop-tooltip-list-attr-rezerv-obj {&attr-rezerv-obj-invngbeg_tooltip},~
{&attr-rezerv-obj-invngend_tooltip},~
{&attr-rezerv-obj-negmanuf_tooltip},~
{&attr-rezerv-obj-negparts_tooltip},~
{&attr-rezerv-obj-prcshfc0_tooltip},~
{&attr-rezerv-obj-prcshrs0_tooltip},~
{&attr-rezerv-obj-prcshrs1_tooltip},~
{&attr-rezerv-obj-prdocfc0_tooltip},~
{&attr-rezerv-obj-prdocrs0_tooltip},~
{&attr-rezerv-obj-prdocrs1_tooltip},~
{&attr-rezerv-obj-prsalpr_tooltip}
&scop level-way-attr-rezerv-obj "obj,host,global"
&scop up-way-attr-rezerv-obj "rezerv-obj,rezerv-obj,rezerv-obj"


/*Набор параметров для работы с изображениями*/
&scop label-attr-images "Параметры для работы с изображениями"
&scop tooltip-attr-images "Параметры для работы с изображениями"
&scop user-can-edit-attr-images true
&scop output-display-attr-images false
&scop other-attr-images 'spr-ext=adm\shattr30.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-images 'character'
&scop prop-label-list-attr-images 'Порядок форматов файлов изображений для поиска и ввода (при хранении изображений вне БД)~
'
&scop global-attr-images true
&scop host-attr-images false
&scop shop-attr-images false
&scop store-attr-images false
&scop db-attr-images false
&scop region-attr-images false
&scop batch-edit-attr-images  0
&scop level-way-attr-images ",,global"
&scop up-way-attr-images ",,images"


/* параметры по Складским документам гловально */
&scop type-attr-nakl-glob            {&type-char}
&scop format-attr-nakl-glob          "x(40)"
&scop label-attr-nakl-glob           "По Складским документам глобально"
&scop tooltip-attr-nakl-glob         "Настройки для Складским документам глобально"
&scop user-can-edit-attr-nakl-glob   true
&scop output-display-attr-nakl-glob  true
&scop other-attr-nakl-glob           'spr-ext=gbl\naklpa1.w':U
&scop prop-type-list-attr-nakl-glob  '~
character,~
logical,~
logical,~
logical,~
logical,~
logical,~
logical,~
logical,~
logical,~
decimal,~
integer,~
character,~
character,~
logical~
':U
&scop prop-label-list-attr-nakl-glob '~
Обработка товара в документе без текущей продажной цены,~
Проверять менеджера и исполнителя,~
Доступен ли импорт с конвертацией,~
Валюта клиента может отличаться от нац.вал. во внешней ПН,~
Работает ли кнопка бар-код в ПН,~
Работает ли поле наценки (калькулятор) в ПН,~
Редактирование типа НДС и НП для внешней ПН,~
Переписывать логи при чтении со сканера,~
Редактировать ли учетные цены создаваемых партий в ПН,~
Максимальный процент транспортных и прочих расходов в ПН,~
До какого знака следует округлять проверяя ПН,~
НсП поставщика в ПН,~
НДС во внешней ПН,~
Задание НДС через сумму в ПН,~
'
&scop prop-list-attr-nakl-glob 'nocurbas,chk-prs,convimp,curcli,is-bcdoc,is-ov,multdtyp,noapndsc,part-prc,prc-exp,rnd-znk,slt-ext,vat-ext,vat-sum'
&scop global-attr-nakl-glob true
&scop host-attr-nakl-glob false
&scop shop-attr-nakl-glob false
&scop store-attr-nakl-glob false
&scop db-attr-nakl-glob false
&scop region-attr-nakl-glob false
&scop batch-edit-attr-nakl-glob  0
&scop attr-nakl-glob-nocurbas_tooltip   (nocurbas) no - запрещает закрывать документ  без текущей продажной цены по товару` yes - разрешает закрывать документ без текущей продажной цены по товару` no_today - запрещает закрывать документы сегодняшним числом без текущей пр. цены и  задает вопрос по заднему  числу` question - запрашивает подтверждение на закрытие документов с товарами без продажной цены
&scop attr-nakl-glob-chk-prs_tooltip    (chk-prs)  Проверять менеджера и исполнителя в документах
&scop attr-nakl-glob-convimp_tooltip    (convimp)  Доступен ли импорт с конвертацией
&scop attr-nakl-glob-curcli_tooltip     (curcli)   Валюта клиента может отличаться от нац.валюты во внешней приходной накладной
&scop attr-nakl-glob-is-bcdoc_tooltip   (is-bcdoc) Работает ли кнопка бар-код во внешней приходной накладной
&scop attr-nakl-glob-is-ov_tooltip      (is-ov)    Работает ли поле наценки (калькулятор) в накладной внешнего прихода
&scop attr-nakl-glob-multdtyp_tooltip   (multdtyp) Редактирование типа НДС и НП для внешней ПН
&scop attr-nakl-glob-noapndsc_tooltip   (noapndsc) Переписывать логи при чтении со сканера
&scop attr-nakl-glob-part-prc_tooltip   (part-prc) Редактировать ли учетные цены создаваемых партий в ПН
&scop attr-nakl-glob-prc-exp_tooltip    (prc-exp)  Максимальный процент транспортных и прочих расходов в ПН
&scop attr-nakl-glob-rnd-znk_tooltip    (rnd-znk) 0 - не использовать копейки` 2 - копейки есть
&scop attr-nakl-glob-slt-ext_tooltip    (slt-ext) Значение НсП вводимое в ПН` Например «0`5»
&scop attr-nakl-glob-vat-ext_tooltip    (vat-ext) Значение НДС вводимое в ПН` Например «0`10`20»
&scop attr-nakl-glob-vat-sum_tooltip    (vat-sum) Задание НДС через сумму в приходной накладной
&scop prop-tooltip-list-attr-nakl-glob {&attr-nakl-glob-nocurbas_tooltip},~
{&attr-nakl-glob-chk-prs_tooltip},~
{&attr-nakl-glob-convimp_tooltip},~
{&attr-nakl-glob-curcli_tooltip},~
{&attr-nakl-glob-is-bcdoc_tooltip},~
{&attr-nakl-glob-is-ov_tooltip},~
{&attr-nakl-glob-multdtyp_tooltip},~
{&attr-nakl-glob-noapndsc_tooltip},~
{&attr-nakl-glob-part-prc_tooltip},~
{&attr-nakl-glob-prc-exp_tooltip},~
{&attr-nakl-glob-rnd-znk_tooltip},~
{&attr-nakl-glob-slt-ext_tooltip},~
{&attr-nakl-glob-vat-ext_tooltip},~
{&attr-nakl-glob-vat-sum_tooltip}
&scop level-way-attr-nakl-glob ",,global"
&scop up-way-attr-nakl-glob ",,nakl-glob"


/* параметры по Печати ФОРМ  глобально */
&scop type-attr-prt-glob            {&type-char}
&scop format-attr-prt-glob          "x(40)"
&scop label-attr-prt-glob           "параметры по Печати форм глобально"
&scop tooltip-attr-prt-glob         "параметры по Печати форм глобально"
&scop user-can-edit-attr-prt-glob   true
&scop output-display-attr-prt-glob  true
&scop other-attr-prt-glob           'spr-ext=adm\prtpglob.p':U
&scop prop-type-list-attr-prt-glob  '~
logical~
,logical~
,character~
,logical~
,logical~
,logical~
,logical~
':U
&scop prop-label-list-attr-prt-glob '~
Печатать строки с 0 до и после инвентаризации в инвент_описи~
,Печатать код фирмы (клиента) при печати названия~
,Печать реквизитов на две строки~
,Сортировка по производителю в старых формах~
,ТОРГ-2 -только товары с расхождениями~
,Печатать сумму в счете-фактуре прописью~
,Печатать артикул в названии товара в Счет-фактуре и Торг-12~
'

&scop prop-list-attr-prt-glob 'invprn0,outprncd,outrecv,sort-prd,torg2-no,outprops,rep-artic'
&scop global-attr-prt-glob true
&scop host-attr-prt-glob false
&scop shop-attr-prt-glob false
&scop store-attr-prt-glob false
&scop db-attr-prt-glob false
&scop region-attr-prt-glob false
&scop batch-edit-attr-prt-glob  0
&scop attr-prt-glob-invprn0_tooltip    (invprn0)   Глобальный. Печатать строки с 0 до и после инвентаризации в инвент. описи
&scop attr-prt-glob-outprncd_tooltip   (outprncd)  Глобальный. В печатных формах печатать после названия фирмы или клиента в скобках код фирмы или клиента
&scop attr-prt-glob-outrecv_tooltip    (outrecv)   Глобальный. Через запятую без пробелов torg12 - ТОРГ12
&scop attr-prt-glob-sort-prd_tooltip   (sort-prd)  Глобальный. Включение  сортировки по производителю в старых печатных формах
&scop attr-prt-glob-sum-from_tooltip   (sum-from)  Глобальный. Нижнее знач для диапазонов сумм для почасового отчета по диапазонам сумм продаж. При наличии настройки sumvals или при отсутствии sum-step и sum-to игнорируетсЯ
&scop attr-prt-glob-outprops_tooltip   (outprops)  Глобальный. Печатать сумму ВСЕГО К ОПЛАТЕ в счете-фактуре прописью
&scop attr-prt-glob-rep-artic_tooltip  (rep-artic) Глобальный. Печатать артикул в названии товара в Счет-фактуре и Торг-12
&scop prop-tooltip-list-attr-prt-glob  {&attr-prt-glob-invprn0_tooltip}~
,{&attr-prt-glob-outprncd_tooltip}~
,{&attr-prt-glob-outrecv_tooltip}~
,{&attr-prt-glob-sort-prd_tooltip}~
,{&attr-prt-glob-torg2-no_tooltip}~
,{&attr-prt-glob-outprops_tooltip}~
,{&attr-prt-glob-rep-artic_tooltip}
&scop level-way-attr-prt-glob ",,global"
&scop up-way-attr-prt-glob ",,prt-glob"


/* параметры по Печати форм фирма */
&scop type-attr-prt-firm            {&type-char}
&scop format-attr-prt-firm          "x(40)"
&scop label-attr-prt-firm           "параметры по Печати форм фирма"
&scop tooltip-attr-prt-firm         "параметры по Печати форм фирма"
&scop user-can-edit-attr-prt-firm   true
&scop output-display-attr-prt-firm  true
&scop other-attr-prt-firm           'spr-ext=adm\prtpfrm.p':U
&scop prop-type-list-attr-prt-firm  '~
logical,~
logical,~
logical~
':U
&scop prop-label-list-attr-prt-firm '~
Печатать в счете-фактуре doc-date вместо fact-date,~
Печать приходной накладной в нац.вал. по текущему курсу,~
Печать ценников на весовой товар (везде)~
'

&scop prop-list-attr-prt-firm 'factur01,incurrat,tick-w'
&scop global-attr-prt-firm false
&scop host-attr-prt-firm true
&scop shop-attr-prt-firm false
&scop store-attr-prt-firm false
&scop db-attr-prt-firm false
&scop region-attr-prt-firm false
&scop batch-edit-attr-prt-firm  0
&scop attr-prt-firm-factur01_tooltip   (factur01) По фирме. yes - впервые для Грин-Лайна
&scop attr-prt-firm-incurrat_tooltip   (incurrat) По фирме. Печать приходной накладной в нац.вал. по текущему курсу
&scop attr-prt-firm-tick-w_tooltip     (tick-w)   По фирме. Если YES` то по умолчанию включена опция «в том числе на весовой товар» при печати ценников. Параметр необязательный` по умолчанию NO
&scop prop-tooltip-list-attr-prt-firm  {&attr-prt-firm-factur01_tooltip},~
{&attr-prt-firm-incurrat_tooltip},~
{&attr-prt-firm-tick-w_tooltip}
&scop level-way-attr-prt-firm ",host,"
&scop up-way-attr-prt-firm ",prt-firm,"


/* параметры по Печати форм по объектам */
&scop type-attr-prt-obj            {&type-char}
&scop format-attr-prt-obj          "x(40)"
&scop label-attr-prt-obj           "параметры по Печати ФОРМ"
&scop tooltip-attr-prt-obj         "параметры по Печати ФОРМ по объектам"
&scop user-can-edit-attr-prt-obj   true
&scop output-display-attr-prt-obj  true
&scop other-attr-prt-obj           'spr-ext=adm\prtpobj.p':U
&scop prop-type-list-attr-prt-obj  '~
logical,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character,~
character~
':U
&scop prop-label-list-attr-prt-obj '~
Наименование товара в накладных печатать в 2 стр,~
Файл для печати внеш. ПН,~
Печатать в заголовках форм <Утверждена Постановлением>,~
не печатать <дата>,~
не печатать <скидка>,~
не печатать <реквизиты ЕГРИП>,~
должна быть задана фирма для печати накладных,~
не печатать <номер документа>,~
Адрес фирмы в графе Грузоотправитель/Грузополучатель из настроек объекта,~
не печатать <примечание>,~
не печатать <Цены указаны в нац.вал.>,~
№ платёжно-расчёт. док-та в счёте-фактуре,~
не печатать <подписи из БД>,~
не печатать последнюю колонку,~
Адрес контрагента в графе Грузополучатель/Грузоотправитель почтовый,~
В графе <Грузоотправитель> печатаются реквизиты объекта,~
Адрес фирмы в графе Грузоотправитель/Грузополучатель почтовый,~
Печатать в графе «Руководитель»,~
Печатать в графе «Гл. бухгалтер»,~
В графе «Отпуск груза разрешил»,~
Печать в графе «Отпуск груза произвел»~
'

&scop prop-list-attr-prt-obj 'fgdsnind,in-docpr,outappr,outdate,outdisc,outegrp,outhold,outnum,outobj,outprim,outrubl,outssdoc,outsubs,outt12,outares,outsend,outasend,outR,outB,outogr,outC'
&scop global-attr-prt-obj false
&scop host-attr-prt-obj false
&scop shop-attr-prt-obj true
&scop store-attr-prt-obj true
&scop db-attr-prt-obj false
&scop region-attr-prt-obj false
&scop batch-edit-attr-prt-obj  0
&scop attr-prt-obj-FGdsNinD_tooltip   (FGdsNinD) Наименование товара в накладных печатать полностью (в несколько строчек)
&scop attr-prt-obj-in-docpr_tooltip   (in-docpr) Вызывается процедура печати внешней накладной. Если пусто вызывается стандартная приходная накладна
&scop attr-prt-obj-outappr_tooltip    (outappr)  Список печатных форм` для которых в заголовках печатать <Утверждена постанавлением...>
&scop attr-prt-obj-outdate_tooltip    (outdate)  Список печатных форм` для которых не печатать поле <дата>
&scop attr-prt-obj-outdisc_tooltip    (outdisc)  Список печатных форм` для которых не печатать поле <скидка>
&scop attr-prt-obj-outegrp_tooltip    (outegrp)  Список печатных форм` для которых не печатать поле <реквизиты ЕГРИП>
&scop attr-prt-obj-outhold_tooltip    (outhold)  Список печатных форм` для которых должна быть задана фирма для печати накладных
&scop attr-prt-obj-outnum_tooltip     (outnum)   Список печатных форм` для которых не печатать <номер документа>
&scop attr-prt-obj-outobj_tooltip     (outobj)   Список печатных форм` для которых в качестве адреса собственной фирмы  в графе <Грузоотправитель> для расходных документов и <Грузополучатель> для приходных накладных печатать адрес объекта
&scop attr-prt-obj-outprim_tooltip    (outprim)  Список печатных форм` для которых не печатать <примечание>
&scop attr-prt-obj-outrubl_tooltip    (outrubl)  Список печатных форм` для которых не печатать <Цены указаны в нац.вал.>
&scop attr-prt-obj-outssdoc_tooltip   (outssdoc) Как печатать номера платёжно-расчётного документа в счёт-фактуре. Номер и дата из: nacl - накладной` findoc - расчётного документа. Если ничего не задано или задано неверно` номер печататься не будет
&scop attr-prt-obj-outsubs_tooltip    (outsubs)  Список печатных форм` для которых не печатать <подписи из БД>
&scop attr-prt-obj-outt12_tooltip     (outt12)   Список печатных форм` для которых не печатать последнюю колонку
&scop attr-prt-obj-outares_tooltip    (outares)  Список печатных форм` для которых вместо юридического адреса контрагента печатать почтовый адрес в графе <Грузополучатель> для расходных документов и  <Грузоотправитель> для приходных
&scop attr-prt-obj-outsend_tooltip    (outsend)  Список печатных форм` для которых вместо реквизитов собственной фирмы в графе <Грузоотправитель> для расходных документов и <Грузополучатель> для приходных документов печатать наименование` адрес` банковские реквизиты объекта
&scop attr-prt-obj-outasend_tooltip   (outasend) Список печатных форм` для которых вместо юридического адреса фирмы печатать  почтовый адрес в графе <Грузоотправитель> для расходных документов и <Грузополучатель> для приходных документов
&scop attr-prt-obj-outR_tooltip       (outR)     Кого печатать в графе «Руководитель»
&scop attr-prt-obj-outB_tooltip       (outB)     Кого печатать в графе «Главный бухгалтер»
&scop attr-prt-obj-outogr_tooltip     (outogr)   Кого печатать в графе «Отпуск груза разрешил»
&scop attr-prt-obj-outC_tooltip       (outC)     Кого печатать в графе «Отпуск груза произвел»
&scop prop-tooltip-list-attr-prt-obj  {&attr-prt-obj-FGdsNinD_tooltip},~
{&attr-prt-obj-in-docpr_tooltip},~
{&attr-prt-obj-outappr_tooltip},~
{&attr-prt-obj-outdate_tooltip},~
{&attr-prt-obj-outdisc_tooltip},~
{&attr-prt-obj-outegrp_tooltip},~
{&attr-prt-obj-outhold_tooltip},~
{&attr-prt-obj-outnum_tooltip},~
{&attr-prt-obj-outobj_tooltip},~
{&attr-prt-obj-outprim_tooltip},~
{&attr-prt-obj-outrubl_tooltip},~
{&attr-prt-obj-outssdoc_tooltip},~
{&attr-prt-obj-outsubs_tooltip},~
{&attr-prt-obj-outt12_tooltip},~
{&attr-prt-obj-outares_tooltip},~
{&attr-prt-obj-outsend_tooltip},~
{&attr-prt-obj-outasend_tooltip},~
{&attr-prt-obj-outR_tooltip},~
{&attr-prt-obj-outB_tooltip},~
{&attr-prt-obj-outogr_tooltip},~
{&attr-prt-obj-outC_tooltip}
&scop level-way-attr-prt-obj "obj,,"
&scop up-way-attr-prt-obj "prt-obj,,"



/* параметры по отчетам глобально */
&scop type-attr-report-glob            {&type-char}
&scop format-attr-report-glob          "x(40)"
&scop label-attr-report-glob           "параметры по Отчетам глобально"
&scop tooltip-attr-report-glob         "параметры по Отчетам глобально"
&scop user-can-edit-attr-report-glob   true
&scop output-display-attr-report-glob  true
&scop other-attr-report-glob           'spr-ext=adm\reptglob.p':U
&scop prop-type-list-attr-report-glob  '~
logical~
,date~
,character~
,decimal~
,decimal~
,decimal~
,character~
,integer~
,character~
,integer~
,integer~
,logical~
,logical~
':U
&scop prop-label-list-attr-report-glob '~
Есть отчеты Actuate~
,Декларация об объемах розничной продажи алк-я~
,Сортировка топлива в отчете по октановому числу~
,Нижнее знач.~
,Шаг~
,Верхнее знач.~
,Список~
,Код группы <Алкогольные товары>~
,Сортировка типов касс.пл-жей в отчете по АВТОКУШ~
,Формат сменного отчета~
,Алгоритм расчета плотности в отчетах~
,Excel для отчетов - защита от редактирования~
,Вывод отчетов в EXCEL ~
'

&scop prop-list-attr-report-glob 'actuate,ardecldt,rep-sort,sum-from,sum-step,sum-to,sumvals,alcgrpgd,cplot,rep-shift-format,cdens,rep-password,rep-excel'
&scop global-attr-report-glob true
&scop host-attr-report-glob false
&scop shop-attr-report-glob true
&scop store-attr-report-glob true
&scop db-attr-report-glob false
&scop region-attr-report-glob false
&scop batch-edit-attr-report-glob  0
&scop attr-report-glob-actuate_tooltip    (actuate)   Глобальный. Есть возможность формирования отчетов через внешнюю программу Actuate
&scop attr-report-glob-ardecldt_tooltip   (ardecldt)  Глобальный. Дата начала формирования отчета Декларация об объемах розничной продажи алк
&scop attr-report-glob-rep-sort_tooltip   (rep-sort)  Глобальный. Перечень топливных кодов. Предполагается` что топливо в списке будут перечисленны по возрастанию октанового числа. Порядок вывода видов топлива в отчетах <<Отчет диспетчера>> <<Расшифровка реализации>> <<Отчет по АВТОКУШ>> соответствует порядку перечисления кодов в этом параметре
&scop attr-report-glob-sum-from_tooltip   (sum-from)  Глобальный. Нижнее знач для диапазонов сумм для почасового отчета по диапазонам сумм продаж. При наличии настройки sumvals или при отсутствии sum-step и sum-to игнорируетсЯ
&scop attr-report-glob-sum-step_tooltip   (sum-step)  Глобальный. Шаг для диапазонов сумм для почасового отчета по диапазонам сумм продаж. При наличии настройки sumvals или при отсутствии sum-from и sum-to игнорируетсЯ
&scop attr-report-glob-sum-to_tooltip     (sum-to)    Глобальный. Верхнее знач для диапазонов сумм для почасового отчета по диапазонам сумм продаж. При наличии настройки sumvals или при отсутствии sum-step и sum-from игнорируетсЯ
&scop attr-report-glob-sumvals_tooltip    (sumvals)   Глобальный. Список диапазонов сумм для почасового отчета по диапазонам сумм продаж` например <20_30`30_40> – т.е. список непересекающихся` примыкающих диапазонов – [нижнее-значение]_[верхнее значение] – имеет приоритет на настройками sum-step` sum-from и sum-to
&scop attr-report-glob-alcgrpgd_tooltip   (alcgrpgd)  Глобальный. Для Отчета <Декларация об объемах розничной продажи алкогольной продукции (Калуга)> нужно выбрать из классификатора групп номер группы с АЛКОГОЛЕМ
&scop attr-report-glob-cplot_tooltip      (cplot)     Глобальный. Перечень типов касс.платежей - билетов лотереи АВТОКУШ. Порядок вывода типов касс.платежа в отчетах <<Отчет по АВТОКУШ>> соответствует порядку перечисления кодов в этом параметре
&scop attr-report-glob-shift-rep-format_tooltip  (rep-shift-format) Глобальный. Формат сменного отчета
&scop attr-report-glob-cdens_tooltip      (cdens)     Глобальный. По средней - плотность чека брать из документа продажи. По чекам - в каждом чеке плотность считается по выставленному алгоритму.
&scop attr-report-glob-rep-password_tooltip  (rep-password) Глобальный. Excel для отчетов - защита от редактирования
&scop attr-report-glob-rep-excel_tooltip  (rep-excel) Глобальный. Вывод отчетов в EXCEL
&scop prop-tooltip-list-attr-report-glob  {&attr-report-glob-actuate_tooltip}~
,{&attr-report-glob-ardecldt_tooltip}~
,{&attr-report-glob-rep-sort_tooltip}~
,{&attr-report-glob-sum-from_tooltip}~
,{&attr-report-glob-sum-step_tooltip}~
,{&attr-report-glob-sum-to_tooltip}~
,{&attr-report-glob-sumvals_tooltip}~
,{&attr-report-glob-alcgrpgd_tooltip}~
,{&attr-report-glob-cplot_tooltip}~
,{&attr-report-glob-rep-shift-format_tooltip}~
,{&attr-report-glob-cdens_tooltip}~
,{&attr-report-glob-rep-password_tooltip} ~
,{&attr-report-glob-rep-excel_tooltip}

&scop level-way-attr-report-glob "obj,,global"
&scop up-way-attr-report-glob "prt-glob,,report-glob"


/* параметры отчетам фирма */
&scop type-attr-report-firm            {&type-char}
&scop format-attr-report-firm          "x(40)"
&scop label-attr-report-firm           "параметры по Отчетам фирма"
&scop tooltip-attr-report-firm         "параметры по Отчетам фирма"
&scop user-can-edit-attr-report-firm   true
&scop output-display-attr-report-firm  true
&scop other-attr-report-firm           'spr-ext=adm\reptfrm.p':U
&scop prop-type-list-attr-report-firm  '~
character~
':U
&scop prop-label-list-attr-report-firm '~
Разделитель колонок при экспорте в Excel~
'

&scop prop-list-attr-report-firm 'xl-delim'
&scop global-attr-report-firm false
&scop host-attr-report-firm true
&scop shop-attr-report-firm false
&scop store-attr-report-firm false
&scop db-attr-report-firm false
&scop region-attr-report-firm false
&scop batch-edit-attr-report-firm  0
&scop attr-report-firm-xl-delim_tooltip   (xl-delim) По фирме. Разделитель колонок при старом экспорте в Excel
&scop prop-tooltip-list-attr-report-firm  {&attr-report-firm-xl-delim_tooltip}
&scop level-way-attr-report-firm ",host,"
&scop up-way-attr-report-firm ",report-firm,"


/* параметры по отчетам по объектам */
&scop type-attr-report-obj            {&type-char}
&scop format-attr-report-obj          "x(40)"
&scop label-attr-report-obj           "параметры по Отчетам"
&scop tooltip-attr-report-obj         "параметры по Отчетам по объектам"
&scop user-can-edit-attr-report-obj   true
&scop output-display-attr-report-obj  true
&scop other-attr-report-obj           'spr-ext=adm\reptobj.p':U
&scop prop-type-list-attr-report-obj  '~
logical,~
character~
':U
&scop prop-label-list-attr-report-obj '~
Печатать номера Z-отчетов в сменном отчете (1-4 л.),~
1-ый лист сменного отчета (топливо)~
'

&scop prop-list-attr-report-obj 'prt-z-no,shft-qty'
&scop global-attr-report-obj false
&scop host-attr-report-obj false
&scop shop-attr-report-obj true
&scop store-attr-report-obj true
&scop db-attr-report-obj false
&scop region-attr-report-obj false
&scop batch-edit-attr-report-obj  0
&scop attr-report-obj-prt-z-no_tooltip   (prt-z-no) Печатать или нет номера Z-отчетов в 1 - 4 листах сменного отчета
&scop attr-report-obj-shft-qty_tooltip   (shft-qty) Какое количество (в кг) из сверки брать для 1-го листа сменного отчета system-cli-qnty или state-cli-qnty (расчетно-книжный остаток)
&scop prop-tooltip-list-attr-report-obj  {&attr-report-obj-prt-z-no_tooltip},{&attr-report-obj-shft-qty_tooltip}
&scop level-way-attr-report-obj "obj,,"
&scop up-way-attr-report-obj "report-obj,,"



/* настройки code-range  */
&scop label-attr-code-range "Опции работы с Диапазонами кодов"
&scop tooltip-attr-code-range "Опции работы с Диапазонами кодов"
&scop user-can-edit-attr-code-range true
&scop output-display-attr-code-range false
&scop other-attr-code-range 'spr-ext=adm\shattr32.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-code-range 'integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer'
&scop prop-label-list-attr-code-range '~
Размер диапазона для соственных кодов товаров~
,Размер диапазона для кодов договоров~
,Размер диапазона для кодов ДК~
,Размер диапазона для кодов правил скидок и расписаний~
,Размер диапазона для кодов организаций~
,Размер диапазона для кодов физ.лиц~
,Размер диапазона для глобальных весовых кодов~
,Размер диапазона для локальных весовых кодов~
,Размер диапазона для локальных взвешиваемых кодов~
,Размер диапазона для глобальных взвешиваемых кодов~
,Размер диапазона для глобальных кодов точек привязки~
,Размер диапазона для локальных штучных кодов для весов~
,Размер диапазона для глобальных кодов финансовых документов~
'
&scop global-attr-code-range true
&scop host-attr-code-range false
&scop shop-attr-code-range false
&scop store-attr-code-range false
&scop db-attr-code-range true
&scop region-attr-code-range false
&scop batch-edit-attr-code-range  0
&scop level-way-attr-code-range ",db,global"
&scop up-way-attr-code-range ",code-range,code-range"


/* Настройки для экспорта  */
&scop label-attr-bge-export "Настройки для экспорта"
&scop tooltip-attr-bge-export "Настройки для экспорта"
&scop user-can-edit-attr-bge-export true
&scop output-display-attr-bge-export false
&scop other-attr-bge-export 'spr-ext=adm\shattr34.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-bge-export 'logical,logical,logical,character,character,character,character,character'
&scop prop-label-list-attr-bge-export '~
Экспорт всех объектов~
,Удалять нули в начале номеров дисконтных карт~
,Экспорт справочников видов оплат типов кассовых платежей и дисконтных карт~
,Список шаблонов названий файлов выгрузки документов и товаров по дням~
,Вариант создания файлов выгрузки~
,Форматы выгрузки~
,Способ выгрузки сменных объектов~
,Контрагенты для которых внешний приход экспортируется как внутренний~
'
&scop global-attr-bge-export true
&scop host-attr-bge-export false
&scop shop-attr-bge-export false
&scop store-attr-bge-export false
&scop db-attr-bge-export true
&scop region-attr-bge-export false
&scop batch-edit-attr-bge-export  0
&scop level-way-attr-bge-export ",db,global"
&scop up-way-attr-bge-export ",bge-export,bge-export"



/* Настройки АВТОПРОЦЕССОВ  */
&scop label-attr-auto-task           "Настройки АВТОПРОЦЕССОВ"
&scop tooltip-attr-auto-task         "Настройки АВТОПРОЦЕССОВ"
&scop user-can-edit-attr-auto-task   true
&scop output-display-attr-auto-task  true
&scop other-attr-auto-task 'spr-ext=adm\shattrat.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-auto-task 'character,character,integer':U
&scop prop-label-list-attr-auto-task 'email на который отсылать сообщения,список пользователей для авто процессов,Максимальное количество очищаемых марок'
&scop global-attr-auto-task true
&scop host-attr-auto-task false
&scop shop-attr-auto-task false
&scop store-attr-auto-task false
&scop db-attr-auto-task true
&scop region-attr-auto-task false
&scop batch-edit-attr-auto-task  0
&scop level-way-attr-auto-task ",db,global"
&scop up-way-attr-auto-task ",auto-task,auto-task"


/* Параметры Ассортиментной политики по объектам */
&scop type-attr-ass-obj            {&type-char}
&scop format-attr-ass-obj          "x(40)"
&scop label-attr-ass-obj           "Настройки по Ассортиментной политике"
&scop tooltip-attr-ass-obj         "Параметры настройки по Ассортиментной политике по объектам"
&scop user-can-edit-attr-ass-obj   true
&scop output-display-attr-ass-obj  true
&scop other-attr-ass-obj           'spr-ext=gbl\asspa.w':U
&scop prop-type-list-attr-ass-obj  'integer,integer,integer,integer':U
&scop prop-label-list-attr-ass-obj 'Срок удаления из Ассортиментных матриц товара с ИЖТ на ВЫВОД из АССОРТИМЕНТА,Критический срок годности товара,Количество дней в статусе ИЖТ (Новинка) для перевода в основную группу,Допустимый процент отклонения матрицы от шаблона'
&scop prop-list-attr-ass-obj       'ass-srokiztdel,crit-srokgod,ass-num-days-igt,ass-proc-matr-shabl'
&scop global-attr-ass-obj true
&scop host-attr-ass-obj true
&scop shop-attr-ass-obj true
&scop store-attr-ass-obj true
&scop db-attr-ass-obj false
&scop region-attr-ass-obj false
&scop batch-edit-attr-ass-obj  0
&scop attr-ass-obj-ass-srokiztdel_tooltip  (ass-srokiztdel) По ИЖТ в статусе на вывод из ассортимента` анализируется дата последнего изменения ИЖТ` сравнивается с текущей и если срок больше или равен заданному параметру` товар выводится из ассортимента
&scop attr-ass-obj-crit-srokgod_tooltip    (crit-srokgod) Критический срок годности товара  в днях` для вывода из "Основной группы"
&scop attr-ass-obj-ass-num-days-igt_tooltip  (ass-num-days-igt) Количество дней в статусе ИЖТ "Новинка" для автоматического перевода в ИЖТ "Основная группа"
&scop attr-ass-obj-ass-proc-matr-shabl_tooltip   (ass-proc-matr-shabl) Допустимый процент отклонения матрицы от шаблона
&scop prop-tooltip-list-attr-ass-obj      {&attr-ass-obj-ass-srokiztdel_tooltip},{&attr-ass-obj-crit-srokgod_tooltip},{&attr-ass-obj-ass-num-days-igt_tooltip},{&attr-ass-obj-ass-proc-matr-shabl_tooltip}
&scop level-way-attr-ass-obj "obj,host,global"
&scop up-way-attr-ass-obj "ass-obj,ass-obj,ass-obj"


/* Настройки размеров окон  */
&scop label-attr-wnd-size "Настройки размеров окон"
&scop tooltip-attr-wnd-size "Настройки размеров окон"
&scop user-can-edit-attr-wnd-size true
&scop output-display-attr-wnd-size false
&scop other-attr-wnd-size 'spr-ext=adm\shattr35.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-wnd-size 'logical,logical'
&scop prop-label-list-attr-wnd-size '~
Максимизировать окна при открытии~
,Сохранять внешний вид окна~
'
&scop global-attr-wnd-size TRUE
&scop host-attr-wnd-size false
&scop shop-attr-wnd-size false
&scop store-attr-wnd-size false
&scop db-attr-wnd-size false
&scop region-attr-wnd-size false
&scop batch-edit-attr-wnd-size  0
&scop level-way-attr-wnd-size ",,global"
&scop up-way-attr-wnd-size ",,wnd-size"



/* Настройки даты и смены на объекте  */
&scop label-attr-obj-date "Настройки даты и смены на объекте"
&scop tooltip-attr-obj-date "Настройки даты и смены на объекте"
&scop user-can-edit-attr-obj-date true
&scop output-display-attr-obj-date false
&scop other-attr-obj-date 'spr-ext=adm\shattr36.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-obj-date 'logical,logical,logical,integer,integer'
&scop prop-label-list-attr-obj-date '~
Автоматическое изменение даты на обычном объекте~
,Автоматическое изменение даты на сменном объекте~
,Новый принцип формирования номеров смен~
,Допустимая разница между календарной и сменной датами~
,Допустимое превышение ВРЕМЕНИ ЗАКРЫТИЯ СМЕНЫ над текущим (в минутах)~
'
&scop global-attr-obj-date TRUE
&scop host-attr-obj-date TRUE
&scop shop-attr-obj-date TRUE
&scop store-attr-obj-date TRUE
&scop db-attr-obj-date false
&scop region-attr-obj-date false
&scop batch-edit-attr-obj-date  0
&scop level-way-attr-obj-date "obj,host,global"
&scop up-way-attr-obj-date "obj-date,obj-date,obj-date"

/* Параметры для работы с ФГИС Меркурий */
&scop type-attr-mercur            {&type-char}
&scop format-attr-mercur          "x(40)"
&scop label-attr-mercur           "Параметры для работы с ФГИС Меркурий"
&scop tooltip-attr-mercur         "Параметры для работы с ФГИС Меркурий"
&scop user-can-edit-attr-mercur   true
&scop output-display-attr-mercur  true
&scop other-attr-mercur           'spr-ext=gbl\mercur.w':U
&scop prop-type-list-attr-mercur  'character,character,character,character,logical,logical,integer,character,integer,character,character,character,logical':U
&scop prop-label-list-attr-mercur 'APIKey,Логин входа в ИС,Логин,Пароль,Разрешено вводить код ВСД вручную,Разрешено закрывать документ без указ. ВСД,Тип взаимодействия,Настройки для печати QR-кода,Сервер,Адрес прокси-сервера,логин,пароль,SSL прокси'
&scop prop-list-attr-mercur       'apikey,login_is,login,password,manual-vcd,close,type-connect,qrcode,server,proxy-addres,proxy-login,proxy-pswd,proxy-ssl'
&scop global-attr-mercur true
&scop host-attr-mercur true
&scop shop-attr-mercur true
&scop store-attr-mercur true
&scop db-attr-mercur false
&scop region-attr-mercur false
&scop batch-edit-attr-mercur  0
&scop level-way-attr-mercur "obj,host,global"
&scop up-way-attr-mercur "mercur,mercur,mercur"

/* Настройки производства  */
&scop label-attr-fbrattr "Настройки производства"
&scop tooltip-attr-fbrattr "Настройки производства"
&scop user-can-edit-attr-fbrattr true
&scop output-display-attr-fbrattr false
&scop other-attr-fbrattr 'spr-ext=adm\shattr37.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-fbrattr 'logical,logical,logical,logical,integer,decimal,decimal'
&scop prop-label-list-attr-fbrattr '~
Первый подходящий рецепт при рекурсивном производстве~
,Ручное заполнение альтернативного производства~
,При раскрутке рецептов прибавлять требуемое количество к уже произведенному~
,Возможность изменения локальных рецептов на глобальные~
,Детализация записи в историю~
,Мин. % наценки производства~
,Макс. % наценки производства~
'
&scop global-attr-fbrattr TRUE
&scop host-attr-fbrattr TRUE
&scop shop-attr-fbrattr TRUE
&scop store-attr-fbrattr TRUE
&scop db-attr-fbrattr FALSE
&scop region-attr-fbrattr FALSE
&scop batch-edit-attr-fbrattr  0
&scop level-way-attr-fbrattr "obj,host,global"
&scop up-way-attr-fbrattr "fbrattr,fbrattr,fbrattr"



/* Настройки работы с ТОПЛИВОМ  */
&scop label-attr-petrol           "Настройки работы с ТОПЛИВНЫМ товаром"
&scop tooltip-attr-petrol         "Настройки работы с ТОПЛИВНЫМ товаром"
&scop user-can-edit-attr-petrol   true
&scop output-display-attr-petrol  true
&scop other-attr-petrol 'spr-ext=adm\shattrpt-fld.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-petrol 'logical,character,logical,logical,logical,character,character,integer,logical,integer,integer,character,integer,integer,logical,character,character,character,decimal,decimal,character,decimal,decimal,logical,logical,logical,character,integer,logical,logical,integer,logical,integer':U
&scop prop-label-list-attr-petrol '~
Расхождение в инвентаризации по сверке делать без учета погрешности измерения,~
Алгоритм вычисления плотности для продаж,~
Автоматические сверки создавать только по измеряемым резервуарам,~
Автоматические сверки создавать с чтением всех счетчиков ТРК,~
Автом. создание инв. счетчиков ТРК при переполнении разрядности эл. счетчика,~
Тип ввода топлива в документах прихода внешнего,~
Тип ввода топлива во всех документах кроме прихода внешнего,~
Контрагент для списания ЕУ при инвентаризации топлива по сверке,~
В документы по умолчанию ставится плотность и темп. из предыдущего документа,~
Настройки инвентаризации по сверке,~
Температура к которой приводится плотность и объем (°С),При воде в сверке отправлять сообщения на список адресов,~
Допустимый % расхождения массы в резервуаре,~
Алгоритм принятия топлива к учету,~
Обязательный выбор автотранспорта из справочника,~
Погрешность изм массы для горизонтальных резер,~
Погрешность изм массы для вертикальных резер,~
Обязательные поля доп.инфо ПН,~
Отклонение объема,~
Отклонение температуры,~
Отклонение плотности,~
Отклонение воды~,~
Допустимый % расхождения массы при приеме СУГ,~
Контроль свободного объема в резервуаре при приеме НП,~
Обязательный выбор этапа для приема газовоза,~
Разрешить ручное заполнение документа приёма НП при поставках с собственных НБ,~
Обязательные поля в секциях ПН,~
Время на сканирование QR-кода (мс),~
Автозаполнение НП,~
Отправлять блокировку пистолетов при приемке,~
Timeout ожидания подтверждения блокировки пистолетов,~
Контроль свободного объема в резервуаре при приеме СУГ,~
Время пропуска данных автоматической сверки после приема НП~
'
&scop global-attr-petrol true
&scop host-attr-petrol true
&scop shop-attr-petrol true
&scop store-attr-petrol true
&scop db-attr-petrol false
&scop region-attr-petrol false
&scop batch-edit-attr-petrol  0
&scop level-way-attr-petrol "obj,host,global"
&scop up-way-attr-petrol "petrol,petrol,petrol"

/*Параметры POS staff-options*/
&scop label-attr-staff-options "Параметры работы с пользователями и персоналом"
&scop tooltip-attr-staff-options "Параметры работы с пользователями и персоналом"
&scop user-can-edit-attr-staff-options true
&scop output-display-attr-staff-options false
&scop other-attr-staff-options 'cd/spr-ext=adm\shattr40.w/init-ext=adm\shattri.p':U
&scop prop-type-list-attr-staff-options 'logical,logical,logical,integer,integer,integer,integer,integer,integer,integer,integer':U
&scop prop-label-list-attr-staff-options '~
Запрет на ввод произвольных данных при вводе персонала смены,~
Обязательное сочетание цифровых и буквенных символов,~
Обязательное сочетание цифровых и буквенных символов (адм),~
Минимальная длина пароля,~
Минимальная длина пароля (адм),~
Время жизни пароля,~
Время жизни пароля (адм),~
Время до блокировки пользователя после окончания действия пароля,~
Время до блокировки пользователя после окончания действия пароля (адм),~
Колличество старых паролей с которыми не должен совпадать новый пароль,~
Колличество старых паролей с которыми не должен совпадать новый пароль (адм)~
'
&scop prop-list-attr-staff-options 'noanshftstaff,obyznumbukv,obyznumbukvadm,minparol,minparoladm,TimeAvail,TimeAvailadm,TimeBlock,TimeBlockAdm,LastPaswd,LastPaswdAdm':U
&scop db-attr-staff-options  false
&scop region-attr-staff-options  false
&scop global-attr-staff-options true
&scop host-attr-staff-options false
&scop shop-attr-staff-options false
&scop store-attr-staff-options false
&scop batch-edit-attr-staff-options 0
&scop level-way-attr-staff-options ",,global"
&scop up-way-attr-staff-options "staff,staff,staff,staff,staff,staff,staff,staff,staff,staff,staff"


/* Настройки правил ИЖТ  */
&scop label-attr-izt-rul           "Настройки правил ИЖТ"
&scop tooltip-attr-izt-rul         "Настройки правил ИЖТ"
&scop user-can-edit-attr-izt-rul   false
&scop output-display-attr-izt-rul  false
&scop other-attr-izt-rul '':U
&scop prop-type-list-attr-izt-rul 'character':U
&scop prop-label-list-attr-izt-rul 'список ответов: можно ли работать с товаром по ИЖТ и по событию'
&scop global-attr-izt-rul true
&scop host-attr-izt-rul false
&scop shop-attr-izt-rul false
&scop store-attr-izt-rul false
&scop db-attr-izt-rul  false
&scop region-attr-izt-rul  false
&scop batch-edit-attr-izt-rul  0
&scop level-way-attr-izt-rul ",,global"
&scop up-way-attr-izt-rul ",,izt-rul"

/* Электронный документооборот */
&scop type-attr-marking               {&type-char}
&scop format-attr-marking             "x(40)"
&scop label-attr-marking           "Электронный документооборот"
&scop tooltip-attr-marking         "Электронный документооборот"
&scop user-can-edit-attr-marking   true
&scop output-display-attr-marking  true
&scop other-attr-marking           'spr-ext=gbl\marking.w':U

&scop prop-type-list-attr-marking  'logical,logical,logical,integer,character,logical,logical,logical,logical,character,character,character,character,character,character,character,character,character':U 
&scop prop-label-list-attr-marking 'Включена работа с ЭДО для маркированных документов,Включена работа с ЭДО для не маркированных документов,Ручной ввод марок,Допустимое отсутствие КМ для "Серой зоны",Типы маркировок для поэкземплярного учета,Запрет на создание рецептов и маркетинговых акций с маркированными товарами,Использования рецепта Альтернатива только для получения ингредиентов,~
Определение товара по штрих-коду,Автоматическое переключение раскладки на русский,Типы маркировок для объемно-артикульного учета,Типы маркировок переходный период,Разрешена продажа возвращенных товаров,~
Проверка блокировок контролирующих органов,Проверка срока годности,Проверка МРЦ,Проверка владельца,Проверка статуса КМ,Проверка прослеживаемости'
&scop prop-list-attr-marking  'marking-EDO,marking-EDO-NotMark,marking-manual,gray_zone_qnty,marking-type-edo,ban-recipes,ban-altr,bar-code,rus-key,marking-type-artic,marking-type-transitional,marking-type-saleReturn,checkBlock,checkDate,checkMRC,checkOwner,checkStatusKM,checkTracking'

&scop global-attr-marking true
&scop host-attr-marking false
&scop shop-attr-marking true
&scop store-attr-marking true
&scop db-attr-marking false
&scop region-attr-marking false
&scop level-way-attr-marking "obj,,global"
&scop up-way-attr-marking "marking,marking,marking"

/*сюда вставлять новые thbj-attr*/

&scop attr-legacy-code ~
when ~{&~{&attr-code~}~} then do: ~
  assign ~
  p-level = ~{&level-way-~{&attr-code~}~} ~
  p-up-way = ~{&up-way-~{&attr-code~}~} ~
  . ~
end.

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    v-tooltip-code-list =  '~{&prop-tooltip-list-~{&attr-code~}~}' .~
    if v-tooltip-code-list = '' then v-tooltip-code-list = ~{&prop-label-list-~{&attr-code~}~}. ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-label = p-label + ~
    (if p-code = '':U then '':U else (":" + entry(lookup(p-code, ~{&prop-list-~{&attr-code~}~} ), ~{&prop-label-list-~{&attr-code~}~}))). ~
    p-tooltip-code = ~
    (if p-code = '':U then '':U ~
     else (entry(lookup(p-code, ~{&prop-list-~{&attr-code~}~} ), v-tooltip-code-list))) no-error. ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    p-global = ~{&global-~{&attr-code~}~}  ~
    p-host = ~{&host-~{&attr-code~}~}  ~
    p-shop = ~{&shop-~{&attr-code~}~}  ~
    p-store = ~{&store-~{&attr-code~}~}  ~
    p-db = ~{&db-~{&attr-code~}~}  ~
    p-prop-list = ~{&prop-list-~{&attr-code~}~}  ~
    p-prop-type-list = ~{&prop-type-list-~{&attr-code~}~}  ~
    p-prop-label-list = ~{&prop-label-list-~{&attr-code~}~}  ~
    p-region = ~{&region-~{&attr-code~}~} ~
    . ~
  end.

procedure thbjattr_code :

  do
  on error undo, return error return-value
  :
    define input  parameter p-upper-code     as character no-undo . /* код атрибута */
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    define output parameter p-prop-list      as character no-undo . /*список членов секции*/
    define output parameter p-prop-type-list as character no-undo . /*список типов членов секции*/
    define output parameter p-prop-label-list as character no-undo . /*список лейблов членов секции*/
    define output parameter p-global          as logical no-undo .   /*может ли быть задан в глобальном контексте*/
    define output parameter p-host           as logical no-undo .    /*может ли быть задан в контексте фирмы*/
    define output parameter p-shop           as logical no-undo .    /*может ли быть задан в контексте маг*/
    define output parameter p-store          as logical no-undo .    /*может ли быть задан в контексте склад*/
    define output parameter p-db             as logical no-undo .    /*может ли быть задан в контексте БД*/
    define output parameter p-region         as logical no-undo .    /*может ли быть задан в контексте региона*/
           
    if index(p-code, {&delim-par}) > 0 then do:
      p-upper-code = entry(1, p-upper-code, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-upper-code :
      &scop attr-code attr-autosale
      {&attr-temp-full-code}
      &scop attr-code attr-get-chk
      {&attr-temp-full-code}
      &scop attr-code attr-chk-view
      {&attr-temp-full-code}
      &scop attr-code attr-cd-sending
      {&attr-temp-full-code}
      &scop attr-code attr-cd-inf-send
      {&attr-temp-full-code}
      &scop attr-code attr-scale-inf
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibm
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ipc-servispl
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-magia-xml
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-NCR-GM
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-NCR-AS-R
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-omron
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-omron-new
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-IBM-XML
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-r-keeper
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-maria
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th_ibs-th_main
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th_ibs-th_devices
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th_ibs-th_fisreg
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th_ibs-th_rec-print
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th_ibs-th_interface
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th-mob
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th-mob_ibs-th-mob_main
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print
      {&attr-temp-full-code}
      &scop attr-code attr-cd-type-autotank
      {&attr-temp-full-code}
      &scop attr-code attr-alias-tpsi
      {&attr-temp-full-code}
      &scop attr-code attr-abc-sale-day
      {&attr-temp-full-code}
      &scop attr-code attr-abc-global
      {&attr-temp-full-code}
      &scop attr-code attr-ord-global
      {&attr-temp-full-code}
      &scop attr-code attr-ord-obj
      {&attr-temp-full-code}
      &scop attr-code attr-ass-obj
      {&attr-temp-full-code}

      &scop attr-code attr-contr-in
      {&attr-temp-full-code}
      &scop attr-code attr-nakl_par
      {&attr-temp-full-code}
      &scop attr-code attr-overval
      {&attr-temp-full-code}
      &scop attr-code attr-inv-global
      {&attr-temp-full-code}
      &scop attr-code attr-inv-obj
      {&attr-temp-full-code}
      &scop attr-code attr-arh-global
      {&attr-temp-full-code}
      &scop attr-code attr-rezerv-global
      {&attr-temp-full-code}
      &scop attr-code attr-rezerv-obj
      {&attr-temp-full-code}
      &scop attr-code attr-nakl-glob
      {&attr-temp-full-code}
      &scop attr-code attr-prt-glob
      {&attr-temp-full-code}
      &scop attr-code attr-prt-obj
      {&attr-temp-full-code}
      &scop attr-code attr-prt-firm
      {&attr-temp-full-code}
      &scop attr-code attr-report-glob
      {&attr-temp-full-code}
      &scop attr-code attr-report-obj
      {&attr-temp-full-code}
      &scop attr-code attr-report-firm
      {&attr-temp-full-code}


      &scop attr-code attr-fin-global
      {&attr-temp-full-code}
      &scop attr-code attr-fin-plan
      {&attr-temp-full-code}
      /* 26/II-2019 не используется. Атрибуты финансовых документов перенесены в БПА
      &scop attr-code attr-fin-doc
      {&attr-temp-full-code}
      */
      &scop attr-code attr-rt-trn-doc
      {&attr-temp-full-code}
      &scop attr-code attr-gds-ref
      {&attr-temp-full-code}
      &scop attr-code attr-gds-ref_obj
      {&attr-temp-full-code}
      &scop attr-code attr-dc-ref
      {&attr-temp-full-code}
      &scop attr-code attr-cli-all
      {&attr-temp-full-code}
      &scop attr-code attr-cashpays
      {&attr-temp-full-code}
      &scop attr-code attr-wthdoc
      {&attr-temp-full-code}
      &scop attr-code attr-wthdoc_obj
      {&attr-temp-full-code}
      &scop attr-code attr-wthrep
      {&attr-temp-full-code}
      &scop attr-code attr-rum
      {&attr-temp-full-code}
      &scop attr-code attr-rum_obj
      {&attr-temp-full-code}
      &scop attr-code attr-easyfuel
      {&attr-temp-full-code}
      &scop attr-code attr-images
      {&attr-temp-full-code}
      &scop attr-code attr-code-range
      {&attr-temp-full-code}
      &scop attr-code attr-bge-export
      {&attr-temp-full-code}
      &scop attr-code attr-auto-task
      {&attr-temp-full-code}
      &scop attr-code attr-wnd-size
      {&attr-temp-full-code}
      &scop attr-code attr-obj-date
      {&attr-temp-full-code}
      &scop attr-code attr-fbrattr
      {&attr-temp-full-code}
      &scop attr-code attr-petrol
      {&attr-temp-full-code}
      &scop attr-code attr-staff-options
      {&attr-temp-full-code}
      &scop attr-code attr-izt-rul
      {&attr-temp-full-code}
      &scop attr-code attr-srv-auth-ASU
      {&attr-temp-full-code}
      &scop attr-code attr-egais-host
      {&attr-temp-full-code}
      &scop attr-code attr-gisMT
      {&attr-temp-full-code}
      &scop attr-code attr-marking
      {&attr-temp-full-code}
      &scop attr-code attr-mercur
      {&attr-temp-full-code}
      
      /* сюда добавлять новые параметры атрибутов объектов TH */
      otherwise do:
        undo, return error substitute("неизвестный атрибут объекта TH &1", p-upper-code ).
      end.
    end.
  end.
end procedure.

procedure thbjattr_tooltip :
do
on error undo, return error return-value
:

  define input  parameter p-upper-code as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  define output parameter p-tooltip-code  as character no-undo .

  define variable v-tooltip-code-list as character no-undo .

  if index(p-code, {&delim-par}) > 0 then do:
    p-upper-code = entry(1, p-upper-code, {&delim-par}).
    p-code = entry(1, p-code, {&delim-par}).
  end.

  case p-upper-code :
    &scop attr-code attr-autosale
    {&attr-temp-code}
    &scop attr-code attr-get-chk
    {&attr-temp-code}
    &scop attr-code attr-chk-view
    {&attr-temp-code}
    &scop attr-code attr-cd-sending
    {&attr-temp-code}
    &scop attr-code attr-cd-inf-send
    {&attr-temp-code}
    &scop attr-code attr-scale-inf
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibm
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ipc-servispl
    {&attr-temp-code}
    &scop attr-code attr-cd-type-magia-xml
    {&attr-temp-code}
    &scop attr-code attr-cd-type-NCR-GM
    {&attr-temp-code}
    &scop attr-code attr-cd-type-NCR-AS-R
    {&attr-temp-code}
    &scop attr-code attr-cd-type-omron
    {&attr-temp-code}
    &scop attr-code attr-cd-type-omron-new
    {&attr-temp-code}
    &scop attr-code attr-cd-type-IBM-XML
    {&attr-temp-code}
    &scop attr-code attr-cd-type-autotank
    {&attr-temp-code}
    &scop attr-code attr-cd-type-r-keeper
    {&attr-temp-code}
    &scop attr-code attr-cd-type-maria
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_main
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_devices
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_fisreg
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_rec-print
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_interface
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th-mob
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th-mob_ibs-th-mob_main
    {&attr-temp-code}
    &scop attr-code attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print
    {&attr-temp-code}
    &scop attr-code attr-cd-type-autotank
    {&attr-temp-code}
    &scop attr-code attr-alias-tpsi
    {&attr-temp-code}
    &scop attr-code attr-abc-sale-day
    {&attr-temp-code}
    &scop attr-code attr-abc-global
    {&attr-temp-code}
    &scop attr-code attr-ord-global
    {&attr-temp-code}
    &scop attr-code attr-ord-obj
    {&attr-temp-code}
    &scop attr-code attr-ass-obj
    {&attr-temp-code}
    &scop attr-code attr-contr-in
    {&attr-temp-code}
    &scop attr-code attr-overval
    {&attr-temp-code}
    &scop attr-code attr-nakl_par
    {&attr-temp-code}
    &scop attr-code attr-fin-global
    {&attr-temp-code}
    &scop attr-code attr-fin-plan
    {&attr-temp-code}
    
    /* 26/II-2019 не используется. Атрибуты финансовых документов перенесены в БПА
    &scop attr-code attr-fin-doc
    {&attr-temp-code}
    */
    
    &scop attr-code attr-gds-ref
    {&attr-temp-code}
    &scop attr-code attr-gds-ref_obj
    {&attr-temp-code}
    &scop attr-code attr-dc-ref
    {&attr-temp-code}
    &scop attr-code attr-cli-all
    {&attr-temp-code}
    &scop attr-code attr-cashpays
    {&attr-temp-code}
    &scop attr-code attr-wthdoc
    {&attr-temp-code}
    &scop attr-code attr-wthdoc_obj
    {&attr-temp-code}
    &scop attr-code attr-wthrep
    {&attr-temp-code}
    &scop attr-code attr-rum
    {&attr-temp-code}
    &scop attr-code attr-rum_obj
    {&attr-temp-code}
    &scop attr-code attr-easyfuel
    {&attr-temp-code}
    &scop attr-code attr-arh-global
    {&attr-temp-code}
    &scop attr-code attr-inv-global
    {&attr-temp-code}
    &scop attr-code attr-inv-obj
    {&attr-temp-code}
    &scop attr-code attr-rezerv-global
    {&attr-temp-code}
    &scop attr-code attr-rezerv-obj
    {&attr-temp-code}
    &scop attr-code attr-nakl-glob
    {&attr-temp-code}
    &scop attr-code attr-prt-glob
    {&attr-temp-code}
    &scop attr-code attr-prt-obj
    {&attr-temp-code}
    &scop attr-code attr-prt-firm
    {&attr-temp-code}
    &scop attr-code attr-report-glob
    {&attr-temp-code}
    &scop attr-code attr-report-obj
    {&attr-temp-code}
    &scop attr-code attr-report-firm
    {&attr-temp-code}
    &scop attr-code attr-images
    {&attr-temp-code}
    &scop attr-code attr-code-range
    {&attr-temp-code}
    &scop attr-code attr-bge-export
    {&attr-temp-code}
    &scop attr-code attr-auto-task
    {&attr-temp-code}
    &scop attr-code attr-wnd-size
    {&attr-temp-code}
    &scop attr-code attr-obj-date
    {&attr-temp-code}
    &scop attr-code attr-fbrattr
    {&attr-temp-code}
    &scop attr-code attr-petrol
    {&attr-temp-code}
    &scop attr-code attr-staff-options
    {&attr-temp-code}
     &scop attr-code attr-izt-rul
    {&attr-temp-code}
    &scop attr-code attr-srv-auth-ASU
    {&attr-temp-code}
    &scop attr-code attr-egais-host
    {&attr-temp-code}
    &scop attr-code attr-gisMT
    {&attr-temp-code}
    &scop attr-code attr-marking
    {&attr-temp-code}
    &scop attr-code attr-mercur
    {&attr-temp-code}
    /* сюда добавлять новые параметры атрибутов клиентов */
    otherwise do:
      undo, return error substitute("неизвестный атрибут объекта TH &1 &2"
                                    , p-upper-code
                                    , p-code ).
    end.
  end.
end.

end procedure.

procedure thbjattr_value :

  do
  on error undo, return error return-value
  :
    define input  parameter p-obj-type         like ub.thbj-attr.obj-type   no-undo .
    define input  parameter p-obj-code         like ub.thbj-attr.obj-code   no-undo .
    define input  parameter p-upper-code       like ub.thbj-attr.upper-prop-code no-undo .
    define input  parameter p-code             like ub.thbj-attr.prop-code no-undo .
    define output parameter p-value-character  like ub.thbj-attr.property-value-character no-undo .
    define output parameter p-value-date       like ub.thbj-attr.property-value-date no-undo .
    define output parameter p-value-decimal    like ub.thbj-attr.property-value-decimal no-undo .
    define output parameter p-value-integer    like ub.thbj-attr.property-value-integer no-undo .
    define output parameter p-value-logical    like ub.thbj-attr.property-value-logical no-undo .
    define output parameter p-type             as character no-undo .
    define output parameter p-found            as decimal no-undo .

    define buffer buf_thbj-attr for ub.thbj-attr .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list as character no-undo .
    define variable v-prop-type-list as character no-undo .
    define variable v-prop-label-list as character no-undo .
    define variable v-global as logical no-undo .
    define variable v-host as logical no-undo .
    define variable v-shop as logical no-undo .
    define variable v-store as logical no-undo .
    define variable v-db as logical no-undo .
    define variable v-region as logical no-undo .

    run thbjattr_code in this-procedure
      (input  p-upper-code      /* p-code           */
      ,input  p-code           /* p-code           */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_thbj-attr no-lock
      where buf_thbj-attr.obj-type  = p-obj-type
        and buf_thbj-attr.obj-code  = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = p-code
      no-error .
    if avail buf_thbj-attr then do:
      assign
      p-value-character =  buf_thbj-attr.property-value-character
      p-value-date      =  buf_thbj-attr.property-value-date
      p-value-decimal   =  buf_thbj-attr.property-value-decimal
      p-value-integer   =  buf_thbj-attr.property-value-integer
      p-value-logical   =  buf_thbj-attr.property-value-logical
      p-type            =  buf_thbj-attr.prop-value-type
      p-found           =  1.00
      .
    end.
  end.

end procedure.

procedure thbjattr_write :

  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type        like ub.thbj-attr.obj-type   no-undo .
    define input parameter p-obj-code        like ub.thbj-attr.obj-code   no-undo .
    define input parameter p-upper-code      like ub.thbj-attr.upper-prop-code  no-undo .
    define input parameter p-code            like ub.thbj-attr.prop-code  no-undo .
    define input parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
    define input parameter p-value-date      like ub.thbj-attr.property-value-date  no-undo .
    define input parameter p-value-decimal   like ub.thbj-attr.property-value-decimal  no-undo .
    define input parameter p-value-integer   like ub.thbj-attr.property-value-integer  no-undo .
    define input parameter p-value-logical   like ub.thbj-attr.property-value-logical  no-undo .

    define buffer buf_thbj-attr for ub.thbj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list as character no-undo .
    define variable v-prop-type-list as character no-undo .
    define variable v-prop-label-list as character no-undo .
    define variable v-global as logical no-undo .
    define variable v-host as logical no-undo .
    define variable v-shop as logical no-undo .
    define variable v-store as logical no-undo .
    define variable v-db as logical no-undo .
    define variable v-dop as character no-undo .
    define variable v-region as logical no-undo .


    run thbjattr_code in this-procedure
      (input  p-upper-code     /* p-upper-code     */
      ,input  p-code           /* p-code           */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_thbj-attr exclusive-lock
      where buf_thbj-attr.obj-type  = p-obj-type
        and buf_thbj-attr.obj-code  = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = p-code
      no-error .
    if not available buf_thbj-attr then do:
      create buf_thbj-attr .
      assign
        buf_thbj-attr.obj-type  = p-obj-type
        buf_thbj-attr.obj-code  = p-obj-code
        buf_thbj-attr.upper-prop-code = p-upper-code
        buf_thbj-attr.prop-code = p-code
        v-dop = entry(lookup(p-code, v-prop-list), v-prop-type-list)
        buf_thbj-attr.prop-value-type = v-dop
      .
    end.
    CASE buf_thbj-attr.prop-value-type:
      when {&abl-datatype-character} then do:
        assign
        buf_thbj-attr.property-value-character = p-value-character
        .
      end.
      when {&abl-datatype-date} then do:
        assign
        buf_thbj-attr.property-value-date = p-value-date
        .
      end.
      when {&abl-datatype-decimal} then do:
        assign
        buf_thbj-attr.property-value-decimal = p-value-decimal
        .
      end.
      when {&abl-datatype-integer} then do:
        assign
        buf_thbj-attr.property-value-integer = p-value-integer
        .
      end.
      when {&abl-datatype-logical} then do:
        assign
        buf_thbj-attr.property-value-logical = p-value-logical
        .
      end.
    end case.
    release buf_thbj-attr no-error.
    if error-status:error then do:
      return error substitute("Ошибка при сохранение атрибута &1 &2 объекта TH &3&5: &5 &6"
                             , p-upper-code
                             , p-code
                             , p-obj-type
                             , p-obj-code
                             , error-status:get-message(1)
                             , return-value ).
    end.
  end.

end procedure.

procedure thbjattr_delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
    define input parameter p-upper-code   like ub.thbj-attr.upper-prop-code  no-undo .
    define input parameter p-code     like ub.thbj-attr.prop-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_thbj-attr for ub.thbj-attr .

    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list as character no-undo .
    define variable v-prop-type-list as character no-undo .
    define variable v-prop-label-list as character no-undo .
    define variable v-global as logical no-undo .
    define variable v-host as logical no-undo .
    define variable v-shop as logical no-undo .
    define variable v-store as logical no-undo .
    define variable v-db as logical no-undo .
    define variable v-region as logical no-undo .


    run thbjattr_code in this-procedure
      (input  p-upper-code     /* p-upper-code     */
      ,input  p-code           /* p-code           */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_thbj-attr exclusive-lock
      where buf_thbj-attr.obj-type  = p-obj-type
        and buf_thbj-attr.obj-code  = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = p-code
      no-error NO-WAIT.
    if not available buf_thbj-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_thbj-attr no-error .
      if error-status:error then do:
        return error substitute("Ошибка при удалении атрибута &1 &2 объекта TH &3&4: &5 &6"
                              , p-upper-code
                              , p-code
                              , p-obj-type
                              , p-obj-code
                              , error-status:get-message(1)
                              , return-value ).
      end.
      p-deleted = yes.
    end.
  end.

end procedure.

procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table for thbjattr_thbj-attr.
define output parameter p-all-found as decimal no-undo .

define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-jj as integer no-undo .
define variable v-all-found as decimal no-undo .

define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_thbjattr_thbj-attr for thbjattr_thbj-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  run thbjattr_code in this-procedure
    (input  p-upper-code     /* p-upper-code     */
    ,input  '':U             /* p-code           */
    ,output v-label          /* p-label          */
    ,output v-user-can-edit  /* p-user-can-edit  */
    ,output v-output-display /* p-output-display */
    ,output v-other          /* p-other          */
    ,output v-prop-list
    ,output v-prop-type-list
    ,output v-prop-label-list
    ,output v-global
    ,output v-host
    ,output v-shop
    ,output v-store
    ,output v-db
    ,output v-region
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  for each buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = p-obj-type
      and buf_thbj-attr.obj-code = p-obj-code
      and buf_thbj-attr.upper-prop-code = p-upper-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
     if buf_thbj-attr.prop-code = '':U then next.
    if lookup( buf_thbj-attr.prop-code, v-prop-list) = 0 then next .
    if (lookup("compl", v-prop-type-list, {&slash-char}) > 0
    and v-prop-type-list <> buf_thbj-attr.prop-value-type)
    or (lookup("compl", v-prop-type-list, {&slash-char}) = 0
        and entry(lookup( buf_thbj-attr.prop-code, v-prop-list), v-prop-type-list) <> buf_thbj-attr.prop-value-type )
    then next .
    find first buf_thbjattr_thbj-attr where
              buf_thbjattr_thbj-attr.obj-type = p-obj-type
          and buf_thbjattr_thbj-attr.obj-code = p-obj-code
          and buf_thbjattr_thbj-attr.upper-prop-code = p-upper-code
          and buf_thbjattr_thbj-attr.prop-code = buf_thbj-attr.prop-code no-error.

    if not available buf_thbjattr_thbj-attr then do:
      create buf_thbjattr_thbj-attr.
      assign
      buf_thbjattr_thbj-attr.obj-type = p-obj-type
      buf_thbjattr_thbj-attr.obj-code = p-obj-code
      buf_thbjattr_thbj-attr.upper-prop-code = p-upper-code
      buf_thbjattr_thbj-attr.prop-code = buf_thbj-attr.prop-code
      .
    end.
    buffer-copy buf_thbj-attr
    except obj-type obj-code upper-prop-code prop-code
    to buf_thbjattr_thbj-attr
    .
    assign
    v-jj = v-jj + 1.
                                
    if buf_thbj-attr.prop-value-type = {&abl-datatype-void} then do:
      v-all-found = 0.
      run thbjattr_get-section in this-procedure (
                                                    input p-obj-type
                                                   ,input p-obj-code
                                                   ,input buf_thbj-attr.prop-code
                                                   ,input p-mode
                                                   ,input-output table thbjattr_thbj-attr
                                                   ,output v-all-found
                                                   ) no-error.
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
      if v-all-found < 1 then do:
        v-jj = v-jj - 1.
      end.
    end.
  end.
  assign
  p-all-found = v-jj / num-entries(v-prop-list).
end.

end procedure. /* thbjattr_get-section */

procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input parameter table for thbjattr_thbj-attr.

define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-jj as integer no-undo .
define variable v-created as logical no-undo .

define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_thbjattr_thbj-attr for thbjattr_thbj-attr.
define buffer sys-ctrl for ub.sys-ctrl.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  run thbjattr_code in this-procedure
    (input  p-upper-code     /* p-upper-code     */
    ,input  '':U             /* p-code           */
    ,output v-label          /* p-label          */
    ,output v-user-can-edit  /* p-user-can-edit  */
    ,output v-output-display /* p-output-display */
    ,output v-other          /* p-other          */
    ,output v-prop-list
    ,output v-prop-type-list
    ,output v-prop-label-list
    ,output v-global
    ,output v-host
    ,output v-shop
    ,output v-store
    ,output v-db
    ,output v-region
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_thbj-attr exclusive-lock where
            buf_thbj-attr.obj-type = p-obj-type
        and buf_thbj-attr.obj-code = p-obj-code
        and buf_thbj-attr.upper-prop-code = p-upper-code
        and buf_thbj-attr.prop-code = '':U  no-error.
  if not available buf_thbj-attr then do:
    create buf_thbj-attr.
    assign
    buf_thbj-attr.obj-type = p-obj-type
    buf_thbj-attr.obj-code = p-obj-code
    buf_thbj-attr.upper-prop-code = p-upper-code
    buf_thbj-attr.prop-code = '':U
    .
  end.
  for each buf_thbjattr_thbj-attr where
        buf_thbjattr_thbj-attr.upper-prop-code = p-upper-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf_thbjattr_thbj-attr.prop-code = '':U then next.
    if lookup( buf_thbjattr_thbj-attr.prop-code, v-prop-list) = 0 then next .
    if (lookup("compl", v-prop-type-list, {&slash-char}) > 0
    and v-prop-type-list <> buf_thbjattr_thbj-attr.prop-value-type)
    or (lookup("compl", v-prop-type-list, {&slash-char}) = 0
        and entry(lookup( buf_thbjattr_thbj-attr.prop-code, v-prop-list), v-prop-type-list) <> buf_thbjattr_thbj-attr.prop-value-type )
    then next .
    v-created = no.
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = p-obj-type
          and buf_thbj-attr.obj-code = p-obj-code
          and buf_thbj-attr.upper-prop-code = buf_thbjattr_thbj-attr.upper-prop-code
          and buf_thbj-attr.prop-code = buf_thbjattr_thbj-attr.prop-code  no-error.
    if not available buf_thbj-attr then do:
      create buf_thbj-attr.
      assign
      buf_thbj-attr.obj-type = p-obj-type
      buf_thbj-attr.obj-code = p-obj-code
      buf_thbj-attr.upper-prop-code = buf_thbjattr_thbj-attr.upper-prop-code
      buf_thbj-attr.prop-code = buf_thbjattr_thbj-attr.prop-code
      buf_thbj-attr.prop-value-type = buf_thbjattr_thbj-attr.prop-value-type
      v-created = yes
      .
    end.
    if  (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = {&cmp}
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = {&stock}
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = {&shop}
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = '':U
    and buf_thbj-attr.obj-type = {&db}
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = {&cmp}
    and buf_thbj-attr.obj-type = {&stock}
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = {&cmp}
    and buf_thbj-attr.obj-type = {&shop}
    and v-created)
    or (buf_thbjattr_thbj-attr.obj-type = buf_thbj-attr.obj-type)
    then do:
      /*копировать можно только сверху вниз*/
      buffer-copy
      buf_thbjattr_thbj-attr
      using
      property-value-character
      property-value-date
      property-value-decimal
      property-value-integer
      property-value-logical
      prop-value-type
      to buf_thbj-attr.
    end.
    if buf_thbj-attr.prop-value-type = {&abl-datatype-void} then do:
      run thbjattr_set-section in this-procedure (
                                                    input p-obj-type
                                                   ,input p-obj-code
                                                   ,input buf_thbj-attr.prop-code
                                                   ,input table thbjattr_thbj-attr
                                                   ) no-error.
     if error-status:error then do:
       undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
     end.
    end.
  end.
  { gbl/objserref.i }
end.
end procedure. /* thbjattr_set-section */

procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .

define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf2_thbj-attr for ub.thbj-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  for each buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = p-obj-type
      and buf_thbj-attr.obj-code = p-obj-code
      and buf_thbj-attr.upper-prop-code = p-upper-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf2_thbj-attr exclusive-lock where
              rowid(buf2_thbj-attr) = rowid(buf_thbj-attr) no-error.
    delete buf2_thbj-attr.
  end.
end.

end procedure. /* thbjattr_delete-section */


procedure thbjattr_legacy :
do
on error undo, return error return-value
:

  define input  parameter p-upper-code as character no-undo .
  define output parameter p-level   as character no-undo .
  define output parameter p-up-way      as character no-undo .

  case p-upper-code :
    &scop attr-code attr-autosale
    {&attr-legacy-code}
    &scop attr-code attr-get-chk
    {&attr-legacy-code}
    &scop attr-code attr-chk-view
    {&attr-legacy-code}
    &scop attr-code attr-cd-sending
    {&attr-legacy-code}
    &scop attr-code attr-cd-inf-send
    {&attr-legacy-code}
    &scop attr-code attr-scale-inf
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibm
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ipc-servispl
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-magia-xml
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-NCR-GM
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-NCR-AS-R
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-omron
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-omron-new
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-IBM-XML
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-autotank
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-r-keeper
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-maria
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_main
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_devices
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_fisreg
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_rec-print
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th_ibs-th_interface
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th-mob
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th-mob_ibs-th-mob_main
    {&attr-legacy-code}
    &scop attr-code attr-cd-type-ibs-th-mob_ibs-th-mob_rec-print
    {&attr-legacy-code}
    &scop attr-code attr-alias-tpsi
    {&attr-legacy-code}
    &scop attr-code attr-abc-sale-day
    {&attr-legacy-code}
    &scop attr-code attr-abc-global
    {&attr-legacy-code}
    &scop attr-code attr-ord-global
    {&attr-legacy-code}
    &scop attr-code attr-ord-obj
    {&attr-legacy-code}
    &scop attr-code attr-ass-obj
    {&attr-legacy-code}
    &scop attr-code attr-contr-in
    {&attr-legacy-code}
    &scop attr-code attr-nakl_par
    {&attr-legacy-code}
    &scop attr-code attr-overval
    {&attr-legacy-code}
    &scop attr-code attr-inv-global
    {&attr-legacy-code}
    &scop attr-code attr-inv-obj
    {&attr-legacy-code}
    &scop attr-code attr-arh-global
    {&attr-legacy-code}
    &scop attr-code attr-rezerv-global
    {&attr-legacy-code}
    &scop attr-code attr-rezerv-obj
    {&attr-legacy-code}
    &scop attr-code attr-fin-global
    {&attr-legacy-code}
    &scop attr-code attr-fin-plan
    {&attr-legacy-code}
    
    /* 26/II-2019 не используется. Атрибуты финансовых документов перенесены в БПА
    &scop attr-code attr-fin-doc
    {&attr-legacy-code}
    */
    
    &scop attr-code attr-gds-ref
    {&attr-legacy-code}
    &scop attr-code attr-gds-ref_obj
    {&attr-legacy-code}
    &scop attr-code attr-dc-ref
    {&attr-legacy-code}
    &scop attr-code attr-cli-all
    {&attr-legacy-code}
    &scop attr-code attr-cashpays
    {&attr-legacy-code}
    &scop attr-code attr-wthdoc
    {&attr-legacy-code}
    &scop attr-code attr-wthdoc_obj
    {&attr-legacy-code}
    &scop attr-code attr-wthrep
    {&attr-legacy-code}
    &scop attr-code attr-rum
    {&attr-legacy-code}
    {&attr-legacy-code}
    &scop attr-code attr-rum_obj
    {&attr-legacy-code}
    &scop attr-code attr-prt-glob
    {&attr-legacy-code}
    &scop attr-code attr-report-glob
    {&attr-legacy-code}
    &scop attr-code attr-auto-task
    {&attr-legacy-code}
    &scop attr-code attr-izt-rul
    {&attr-legacy-code}
    &scop attr-code attr-nakl-glob
    {&attr-legacy-code}
    &scop attr-code attr-prt-obj
    {&attr-legacy-code}
    &scop attr-code attr-prt-firm
    {&attr-legacy-code}
    &scop attr-code attr-report-obj
    {&attr-legacy-code}
    &scop attr-code attr-report-firm
    {&attr-legacy-code}
    &scop attr-code attr-rt-trn-doc
    {&attr-legacy-code}
    &scop attr-code attr-easyfuel
    {&attr-legacy-code}
    &scop attr-code attr-images
    {&attr-legacy-code}
    &scop attr-code attr-code-range
    {&attr-legacy-code}
    &scop attr-code attr-bge-export
    {&attr-legacy-code}
    &scop attr-code attr-auto-task
    {&attr-legacy-code}
    &scop attr-code attr-wnd-size
    {&attr-legacy-code}
    &scop attr-code attr-obj-date
    {&attr-legacy-code}
    &scop attr-code attr-fbrattr
    {&attr-legacy-code}
    &scop attr-code attr-petrol
    {&attr-legacy-code}
    &scop attr-code attr-staff-options
    {&attr-legacy-code}
    &scop attr-code attr-izt-rul
    {&attr-legacy-code}
    &scop attr-code attr-srv-auth-ASU
    {&attr-legacy-code}
    &scop attr-code attr-egais-host
    {&attr-legacy-code}
    &scop attr-code attr-gisMT
    {&attr-legacy-code}
	&scop attr-code attr-marking
    {&attr-legacy-code}
    &scop attr-code attr-mercur
    {&attr-legacy-code}

    /* сюда добавлять новые параметры  */
    otherwise do:
      undo, return error substitute("неизвестная секция параметров TH &1"
                                    , p-upper-code
                                    ).
    end.
  end.
end.

end procedure.

&scop section-manual-edit-code ~
when ~{&~{&section-code~}~} then do: ~
  if p-code <> '' AND lookup(p-code, ~{&prop-list-~{&section-code~}~} ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ). ~
  assign ~
  p-section-num = integer(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&manual-edit-~{&section-code~}~})). ~
end.

procedure thbjattr_manual-edit :

do
  on error undo, return error
  :

  define input  parameter p-ucode          as character no-undo . /* код секции */
  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .


    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-ucode :
      &scop section-code attr-rum
      {&section-manual-edit-code}

      &scop section-code attr-rum_obj
      {&section-manual-edit-code}

      /* сюда добавлять новые параметры атрибутов thbj */
      otherwise do:
        /*возвратиться 0*/
        /*undo, return error substitute("неизвестный атрибут thbj &1", p-code ).*/
      end.
    end.
  end.
end procedure.





/* ################## */
/* атрибуты товаров */

/* Атрибут для блокирования остальных атрибутов в интерфейсе */
&scop type-attr-gds-attr-lock {&type-log}
&scop format-attr-gds-attr-lock  "yes/no"
&scop label-attr-gds-attr-lock   "Блокировка атрибутов на изменение"
&scop tooltip-attr-gds-attr-lock   "Блокировка атрибутов на изменение"
&scop user-can-edit-attr-gds-attr-lock  false
&scop output-display-attr-gds-attr-lock  false
&scop other-attr-gds-attr-lock  ""
&scop copy-attr-gds-attr-lock  false
&scop manual-edit-attr-gds-attr-lock 0
&scop batch-edit-attr-gds-attr-lock  0

&scop type-attr-alcohol-prod {&type-log}
&scop format-attr-alcohol-prod  "+/ "
&scop label-attr-alcohol-prod   "Алкогольная продукция"
&scop tooltip-attr-alcohol-prod   "Алкогольная продукция"
&scop user-can-edit-attr-alcohol-prod  true
&scop output-display-attr-alcohol-prod  true
&scop other-attr-alcohol-prod  ""
&scop news-attr-alcohol-prod true
&scop copy-attr-alcohol-prod  true
&scop manual-edit-attr-alcohol-prod 0
&scop batch-edit-attr-alcohol-prod  7

/*Требует обязательной маркировки*/
&glob type-attr-mark {&type-log}
&glob format-attr-mark  "+/ "
&glob label-attr-mark   "Товар требует обязательной маркировки"
&glob tooltip-attr-mark   "Товар требует обязательной маркировки"
&glob user-can-edit-attr-mark  true
&glob output-display-attr-mark  true
&glob other-attr-mark  ""
&glob news-attr-mark true
&glob copy-attr-mark  true
&scop manual-edit-attr-mark 0
&scop batch-edit-attr-mark  7

&scop type-attr-egais-name {&type-char}
&scop format-attr-egais-name  "X(100)"
&scop label-attr-egais-name   "Наименование товара в ЕГАИС"
&scop tooltip-attr-egais-name   "Наименование товара в ЕГАИС"
&scop user-can-edit-attr-egais-name  false
&scop output-display-attr-egais-name  false
&scop other-attr-egais-name  ""
&scop news-attr-egais-name true
&scop copy-attr-egais-name  true
&scop manual-edit-attr-egais-name 0
&scop batch-edit-attr-egais-name  0

&scop type-attr-is-gas {&type-log}
&scop format-attr-is-gas  "+/ "
&scop label-attr-is-gas   "Природный газ-топливо"
&scop tooltip-attr-is-gas   "Природный газ-топливо"
&scop user-can-edit-attr-is-gas  false
&scop output-display-attr-is-gas  false
&scop other-attr-is-gas  "check=gds-attr_check-ptrl-divis"
&scop news-attr-is-gas false
&scop copy-attr-is-gas  false
&scop manual-edit-attr-is-gas 6
&scop batch-edit-attr-is-gas  6

&scop type-attr-fuel-type {&type-char}
&scop format-attr-fuel-type  "X(50)"
&scop label-attr-fuel-type   "Тип топлива"
&scop tooltip-attr-fuel-type   "Тип топлива"
&scop user-can-edit-attr-fuel-type  true
&scop output-display-attr-fuel-type  true
&scop other-attr-fuel-type  "spr-ext=ref\gds-ft.p/spr-param=fuel-type/check=gds-attr_check-ptrl-divis"
&scop news-attr-fuel-type true
&scop copy-attr-fuel-type  true
&scop manual-edit-attr-fuel-type 6
&scop batch-edit-attr-fuel-type  6

&scop type-attr-ptrl-without-rvs {&type-log}
&scop format-attr-ptrl-without-rvs  "+/ "
&scop label-attr-ptrl-without-rvs   "Топливо - сверка не требуется"
&scop tooltip-attr-ptrl-without-rvs   "Топливо - сверка не требуется"
&scop user-can-edit-attr-ptrl-without-rvs  true
&scop output-display-attr-ptrl-without-rvs  true
&scop other-attr-ptrl-without-rvs  "check=gds-attr_check-ptrl-divis"
&scop news-attr-ptrl-without-rvs true
&scop copy-attr-ptrl-without-rvs  true
&scop manual-edit-attr-ptrl-without-rvs 6
&scop batch-edit-attr-ptrl-without-rvs  6

&scop type-attr-group-np {&type-char}
&scop format-attr-group-np  "X(50)"
&scop label-attr-group-np   "Группа НП"
&scop tooltip-attr-group-np   "Группа НП"
&scop user-can-edit-attr-group-np  true
&scop output-display-attr-group-np  true
&scop other-attr-group-np  "spr-ext=ref\group-np.w/spr-param=group-np/check=gds-attr_check-group-np"
&scop news-attr-group-np true
&scop copy-attr-group-np  true
&scop manual-edit-attr-group-np 6
&scop batch-edit-attr-group-np  6

&scop type-attr-office-type {&type-char}
&scop format-attr-office-type  "X(50)"
&scop label-attr-office-type   "Тип услуги"
&scop tooltip-attr-office-type   "Тип услуги"
&scop user-can-edit-attr-office-type  true
&scop output-display-attr-office-type  true
&scop other-attr-office-type  "spr-ext=ref\gds-ot.w/spr-param=office-type/check=gds-attr_check-office-type"
&scop news-attr-office-type true
&scop copy-attr-office-type  true
&scop manual-edit-attr-office-type 1
&scop batch-edit-attr-office-type  1

&scop type-attr-mark-type {&type-char}
&scop format-attr-mark-type  "X(50)"
&scop label-attr-mark-type   "Тип маркировки"
&scop tooltip-attr-mark-type   "Тип маркировки"
&scop user-can-edit-attr-mark-type  true
&scop output-display-attr-mark-type  true
&scop other-attr-mark-type  "spr-ext=ref\mark-type.w/spr-param=mark-type/check=gds-attr_check-mark-type"
&scop news-attr-mark-type true
&scop copy-attr-mark-type  true
&scop manual-edit-attr-mark-type 1
&scop batch-edit-attr-mark-type  1

&scop type-attr-emrc-type {&type-char}
&scop format-attr-emrc-type  "X(50)"
&scop label-attr-emrc-type   "Тип ЕМЦ"
&scop tooltip-attr-emrc-type   "Тип ЕМЦ"
&scop user-can-edit-attr-emrc-type  true
&scop output-display-attr-emrc-type  true
&scop other-attr-emrc-type  "cd/spr-ext=ref\emrc-type.w/spr-param=emrc-type/check=gds-attr_check-emrc-type"
&scop news-attr-emrc-type true
&scop copy-attr-emrc-type  true
&scop manual-edit-attr-emrc-type 1
&scop batch-edit-attr-emrc-type  1


&scop type-attr-item-matter-mark {&type-int}
&scop format-attr-item-matter-mark  ">9"
&scop label-attr-item-matter-mark   "Признак предмета расчета"
&scop tooltip-attr-item-matter-mark   "Признак предмета расчета"
&scop user-can-edit-attr-item-matter-mark  true
&scop output-display-attr-item-matter-mark  true
&scop other-attr-item-matter-mark  "spr-ext=ref\gds-imm.w/spr-param=item-matter-mark/check=gds-attr_check-item-matter-mark"
&scop news-attr-item-matter-mark true
&scop copy-attr-item-matter-mark  true
&scop manual-edit-attr-item-matter-mark 1
&scop batch-edit-attr-item-matter-mark  1

&scop type-attr-type-method-calc {&type-char}
&scop format-attr-type-method-calc  ">9"
&scop label-attr-type-method-calc   "Признак способа расчета"
&scop tooltip-attr-type-method-calc   "Признак способа расчета"
&scop user-can-edit-attr-type-method-calc  true
&scop output-display-attr-type-method-calc  true
&scop other-attr-type-method-calc  "spr-ext=ref\gds-tmc.w/spr-param=type-method-calc/check=gds-attr_check-type-method-calc/cd=IBM-XML"
&scop news-attr-type-method-calc true
&scop copy-attr-type-method-calc  true
&scop manual-edit-attr-type-method-calc 1
&scop batch-edit-attr-type-method-calc  1

&scop type-attr-cash-book-id {&type-int}
&scop format-attr-cash-book-id  ">>>>>>>>9"
&scop label-attr-cash-book-id   "Кассовая книга"
&scop tooltip-attr-cash-book-id   "Кассовая книга"
&scop user-can-edit-attr-cash-book-id  true
&scop output-display-attr-cash-book-id  true
&scop other-attr-cash-book-id "" /*"spr-ext=ref\gds-imm.w/spr-param=item-matter-mark/check=gds-attr_check-item-matter-mark"*/
&scop news-attr-cash-book-id true
&scop copy-attr-cash-book-id  true
&scop manual-edit-attr-cash-book-id 1
&scop batch-edit-attr-cash-book-id  1

&scop type-attr-oper-serv-id {&type-int}
&scop format-attr-oper-serv-id  ">>>>>>>>9"
&scop label-attr-oper-serv-id   "Платежный агент"
&scop tooltip-attr-oper-serv-id  "Платежный агент"
&scop user-can-edit-attr-oper-serv-id  true
&scop output-display-attr-oper-serv-id  true
&scop other-attr-oper-serv-id  ""  /*"spr-ext=ref\gds-imm.w/spr-param=item-matter-mark/check=gds-attr_check-item-matter-mark"*/
&scop news-attr-oper-serv-id true
&scop copy-attr-oper-serv-id  true
&scop manual-edit-attr-oper-serv-id 1
&scop batch-edit-attr-oper-serv-id  1

&scop type-attr-is-oss-payment {&type-log}
&scop format-attr-is-oss-payment  "+/ "
&scop label-attr-is-oss-payment   "Платеж ОСС"
&scop tooltip-attr-is-oss-payment   "Платеж оператору сотовой связи"
&scop user-can-edit-attr-is-oss-payment  true
&scop output-display-attr-is-oss-payment  true
&scop other-attr-is-oss-payment  "check=gds-attr_check-is-oss-payment"
&scop news-attr-is-oss-payment true
&scop copy-attr-is-oss-payment  true
&scop manual-edit-attr-is-oss-payment 1
&scop batch-edit-attr-is-oss-payment  1

&scop type-attr-is-loyalty-payment {&type-log}
&scop format-attr-is-loyalty-payment  "+/ "
&scop label-attr-is-loyalty-payment   "Перечисление в систему лояльности"
&scop tooltip-attr-is-loyalty-payment   "Перечисление в систему лояльности"
&scop user-can-edit-attr-is-loyalty-payment  true
&scop output-display-attr-is-loyalty-payment  true
&scop other-attr-is-loyalty-payment  "check=gds-attr_check-is-loyalty-payment"
&scop news-attr-is-loyalty-payment true
&scop copy-attr-is-loyalty-payment  true
&scop manual-edit-attr-is-loyalty-payment 1
&scop batch-edit-attr-is-loyalty-payment  1

&scop type-attr-ban-bonus {&type-log}
&scop format-attr-ban-bonus  "+/ "
&scop label-attr-ban-bonus   "Запрет на участие в бонусных программах\участие в скидке на итог"
&scop tooltip-attr-ban-bonus   "Запрет на участие в бонусных программах\участие в скидке на итог"
&scop user-can-edit-attr-ban-bonus  true
&scop output-display-attr-ban-bonus  true
&scop other-attr-ban-bonus  ""
&scop news-attr-ban-bonus true
&scop copy-attr-ban-bonus  true
&scop manual-edit-attr-ban-bonus 1
&scop batch-edit-attr-ban-bonus  1

&scop type-attr-null-price {&type-log}
&scop format-attr-null-price  "+/ "
&scop label-attr-null-price   "Разрешена нулевая цена"
&scop tooltip-attr-null-price   "Разрешена нулевая цена"
&scop user-can-edit-attr-null-price  true
&scop output-display-attr-null-price  true
&scop other-attr-null-price  ""
&scop news-attr-null-price true
&scop copy-attr-null-price  true
&scop manual-edit-attr-null-price 1
&scop batch-edit-attr-null-price  1

&glob type-attr-fasovka {&type-log}
&glob format-attr-fasovka  "+/ "
&glob label-attr-fasovka   "Товар фасуется"
&glob tooltip-attr-fasovka   "Товар фасуется"
&glob user-can-edit-attr-fasovka  true
&glob output-display-attr-fasovka  true
&glob other-attr-fasovka  ""
&glob news-attr-fasovka true
&glob copy-attr-fasovka  true
&scop manual-edit-attr-fasovka 1
&scop batch-edit-attr-fasovka  1

/*Печатать время приготовления в чеке*/
&glob type-attr-time-coock {&type-log}
&glob format-attr-time-coock  "+/ "
&glob label-attr-time-coock   "Печатать время приготовления в чеке"
&glob tooltip-attr-time-coock   "Печатать время приготовления в чеке"
&glob user-can-edit-attr-time-coock  true
&glob output-display-attr-time-coock  true
&glob other-attr-time-coock  ""
&glob news-attr-time-coock true
&glob copy-attr-time-coock  true
&scop manual-edit-attr-time-coock 1
&scop batch-edit-attr-time-coock  1

/*Требует обязательной маркировки*/
&glob type-attr-mark {&type-log}
&glob format-attr-mark  "+/ "
&glob label-attr-mark   "Товар требует обязательной маркировки"
&glob tooltip-attr-mark   "Товар требует обязательной маркировки"
&glob user-can-edit-attr-mark  true
&glob output-display-attr-mark  true
&glob other-attr-mark  ""
&glob news-attr-mark true
&glob copy-attr-mark  true
&scop manual-edit-attr-mark 0
&scop batch-edit-attr-mark  7

/* Группа товаров на кассе */
&glob type-attr-sum-grp-gl {&type-char}
&glob format-attr-sum-grp-gl  "X(5)"
&glob label-attr-sum-grp-gl   "Группа товаров на кассе"
&glob tooltip-attr-sum-grp-gl   "Номер группы товаров на кассе (IBM-POS)"
&glob user-can-edit-attr-sum-grp-gl  true
&glob output-display-attr-sum-grp-gl  true
&glob other-attr-sum-grp-gl  "spr-ext=gds-glob-sum-grps"
&glob news-attr-sum-grp-gl true
&glob copy-attr-sum-grp-gl  true
&scop manual-edit-attr-sum-grp-gl  1
&scop batch-edit-attr-sum-grp-gl  1

/* Только производство */
&glob type-attr-production-only {&type-log}
&glob format-attr-production-only  "+/-"
&glob label-attr-production-only   "Только производство"
&glob tooltip-attr-production-only   "Используется только для производства (альтернатива)"
&glob user-can-edit-attr-production-only  true
&glob output-display-attr-production-only  true
&glob other-attr-production-only  ""
&glob news-attr-production-only true
&glob copy-attr-production-only  true
&scop manual-edit-attr-production-only  1
&scop batch-edit-attr-production-only  1

/* Является подконтрольным ФГИС "Меркурий" */
&glob type-attr-mercur_FGIS {&type-log}
&glob format-attr-mercur_FGIS  "+/-"
&glob label-attr-mercur_FGIS   "Является подконтрольным ФГИС Меркурий"
&glob tooltip-attr-mercur_FGIS   "Является подконтрольным ФГИС Меркурий"
&glob user-can-edit-attr-mercur_FGIS  true
&glob output-display-attr-mercur_FGIS  true
&glob other-attr-mercur_FGIS  ""
&glob news-attr-mercur_FGIS true
&glob copy-attr-mercur_FGIS  true
&scop manual-edit-attr-mercur_FGIS  1
&scop batch-edit-attr-mercur_FGIS  1

/* Код номенклатурной классификации */
&scop type-attr-gds-CommodityCode {&type-char}
&scop format-attr-gds-CommodityCode  "X(21)"
&scop label-attr-gds-CommodityCode   "Код номенклатурной классификации"
&scop tooltip-attr-gds-CommodityCode   "Код номенклатурной классификации"
&scop user-can-edit-attr-gds-CommodityCode  true
&scop output-display-attr-gds-CommodityCode  true
&scop other-attr-gds-CommodityCode ""
&glob news-attr-gds-CommodityCode true
&scop copy-attr-gds-CommodityCode  true
&scop manual-edit-attr-gds-CommodityCode  1
&scop batch-edit-attr-gds-CommodityCode  1

/* Коды АИС */
&scop type-attr-gds-code-AIS {&type-char}
&scop format-attr-gds-code-AIS  "X(21)"
&scop label-attr-gds-code-AIS   "Коды АИС"
&scop tooltip-attr-gds-code-AIS   "Коды АИС"
&scop user-can-edit-attr-gds-code-AIS  true
&scop output-display-attr-gds-code-AIS  true
&scop other-attr-gds-code-AIS ""
&glob news-attr-gds-code-AIS true
&scop copy-attr-gds-code-AIS  true
&scop manual-edit-attr-gds-code-AIS  6
&scop batch-edit-attr-gds-code-AIS  6

/* Является скоропортящейся продукцией */
&glob type-attr-perishable {&type-log}
&glob format-attr-perishable  "+/-"
&glob label-attr-perishable   "Является скоропортящейся продукцией"
&glob tooltip-attr-perishable   "Является скоропортящейся продукцией"
&glob user-can-edit-attr-perishable  true
&glob output-display-attr-perishable  true
&glob other-attr-perishable  ""
&glob news-attr-perishable true
&glob copy-attr-perishable  true
&scop manual-edit-attr-perishable  1
&scop batch-edit-attr-perishable  1

&glob type-attr-15x80 {&type-char}
&glob format-attr-15x80  "X(255)"
&glob label-attr-15x80   "Текст поля СОСТАВ 15x80 (DIGI-SM)"
&glob tooltip-attr-15x80   "Текст поля СОСТАВ для этикетки 15x80 (DIGI-SM)"
&glob user-can-edit-attr-15x80  true
&glob output-display-attr-15x80  true
&glob other-attr-15x80  "spr-ext=ref\struct-i.w/spr-param=15x80/init=gds-attr_init-15x80"
&glob news-attr-15x80 true
&glob copy-attr-15x80  true
&scop manual-edit-attr-15x80 5
&scop batch-edit-attr-15x80  5

&glob type-attr-8x50 {&type-char}
&glob format-attr-8x50  "X(255)"
&glob label-attr-8x50   "Текст поля СОСТАВ 8x50 (CAS_LP-16x,SHTRIH-M)"
&glob tooltip-attr-8x50   "Текст поля СОСТАВ для этикетки 8x50 (CAS_LP-16x,SHTRIH-M)"
&glob user-can-edit-attr-8x50  true
&glob output-display-attr-8x50  true
&glob other-attr-8x50  "spr-ext=ref\struct-i.w/spr-param=8x50/init=gds-attr_init-8x50"
&glob news-attr-8x50 true
&glob copy-attr-8x50  true
&scop manual-edit-attr-8x50 5
&scop batch-edit-attr-8x50  5


&glob type-attr-6x50 {&type-char}
&glob format-attr-6x50  "X(255)"
&glob label-attr-6x50   "Текст поля СОСТАВ 6x50 (CAS_CL5000 CAS_CL5000J)"
&glob tooltip-attr-6x50   "Текст поля СОСТАВ для этикетки 6x50 (CAS_CL5000 CAS_CL5000J)"
&glob user-can-edit-attr-6x50  true
&glob output-display-attr-6x50  true
&glob other-attr-6x50  "spr-ext=ref\struct-i.w/spr-param=6x50/init=gds-attr_init-6x50"
&glob news-attr-6x50 true
&glob copy-attr-6x50  true
&scop manual-edit-attr-6x50 5
&scop batch-edit-attr-6x50  5

&glob type-attr-calories {&type-dec}
&glob format-attr-calories  ">,>>9.9"
&glob label-attr-calories   "Энерг.ценность ккал на 100г"
&glob tooltip-attr-calories   "Энерг.ценность ккал на 100г"
&glob user-can-edit-attr-calories  true
&glob output-display-attr-calories  true
&glob other-attr-calories  "check=gds-attr_check-can-energy-value"
&glob news-attr-calories true
&glob copy-attr-calories  true
&scop manual-edit-attr-calories 2
&scop batch-edit-attr-calories  2

&glob type-attr-protein {&type-dec}
&glob format-attr-protein  ">9.9"
&glob label-attr-protein   "Белки г на 100г"
&glob tooltip-attr-protein   "Белки г на 100г"
&glob user-can-edit-attr-protein  true
&glob output-display-attr-protein  true
&glob other-attr-protein  "check=gds-attr_check-can-energy-value"
&glob news-attr-protein true
&glob copy-attr-protein  true
&scop manual-edit-attr-protein 2
&scop batch-edit-attr-protein  2

&glob type-attr-fat {&type-dec}
&glob format-attr-fat  ">9.9"
&glob label-attr-fat   "Жиры г на 100г"
&glob tooltip-attr-fat   "Жиры г на 100г"
&glob user-can-edit-attr-fat  true
&glob output-display-attr-fat  true
&glob other-attr-fat  "check=gds-attr_check-can-energy-value"
&glob news-attr-fat true
&glob copy-attr-fat  true
&scop manual-edit-attr-fat 2
&scop batch-edit-attr-fat  2

&glob type-attr-carbohydrate {&type-dec}
&glob format-attr-carbohydrate  ">9.9"
&glob label-attr-carbohydrate   "Углеводы г на 100г"
&glob tooltip-attr-carbohydrate   "Углеводы г на 100г"
&glob user-can-edit-attr-carbohydrate  true
&glob output-display-attr-carbohydrate  true
&glob other-attr-carbohydrate  "check=gds-attr_check-can-energy-value"
&glob news-attr-carbohydrate true
&glob copy-attr-carbohydrate  true
&scop manual-edit-attr-carbohydrate 2
&scop batch-edit-attr-carbohydrate  2


&glob type-attr-calc-cal-rec {&type-log}
&glob format-attr-calc-cal-rec  "+/-"
&glob label-attr-calc-cal-rec   "_Расчет энерг.ценн-ти из основного рец-та"
&glob tooltip-attr-calc-cal-rec   "Расчет энергетической ценности из основного рецепта"
&glob user-can-edit-attr-calc-cal-rec  true
&glob output-display-attr-calc-cal-rec  true
&glob other-attr-calc-cal-rec  ""
&glob news-attr-calc-cal-rec true
&glob copy-attr-calc-cal-rec  false
&scop manual-edit-attr-calc-cal-rec 2
&scop batch-edit-attr-calc-cal-rec  2


&glob type-attr-cash-parts {&type-log}
&glob format-attr-cash-parts  "+/-"
&glob label-attr-cash-parts   "По умолч.торгуется по партиям"
&glob tooltip-attr-cash-parts   "По умолч.торгуется по партиям"
&glob user-can-edit-attr-cash-parts  true
&glob output-display-attr-cash-parts  true
&glob other-attr-cash-parts  ""
&glob news-attr-cash-parts true
&glob copy-attr-cash-parts  true
&scop manual-edit-attr-cash-parts 1
&scop batch-edit-attr-cash-parts  1

&scop type-attr-ptrl-as-good {&type-log}
&scop format-attr-ptrl-as-good  "+/ "
&scop label-attr-ptrl-as-good   "ТНП продается через ТРК"
&scop tooltip-attr-ptrl-as-good   "ТНП продается через ТРК"
&scop user-can-edit-attr-ptrl-as-good  true
&scop output-display-attr-ptrl-as-good  true
&scop other-attr-ptrl-as-good  "check=gds-attr_check-ptrl-divis"
&scop news-attr-ptrl-as-good true
&scop copy-attr-ptrl-as-good  true
&scop manual-edit-attr-ptrl-as-good 6
&scop batch-edit-attr-ptrl-as-good  6

&glob type-attr-dflt-insalepr {&type-log}
&glob format-attr-dflt-insalepr  "+/ "
&glob label-attr-dflt-insalepr   "По умолч. приходуется в продаж.ценах"
&glob tooltip-attr-dflt-insalepr   "По умолч. приходуется в продаж.ценах"
&glob user-can-edit-attr-dflt-insalepr  true
&glob output-display-attr-dflt-insalepr  true
&glob other-attr-dflt-insalepr  ""
&glob news-attr-dflt-insalepr true
&glob copy-attr-dflt-insalepr  false
&scop manual-edit-attr-dflt-insalepr 6
&scop batch-edit-attr-dflt-insalepr  6

/* Диапазоны плотности топлива */
&scop type-attr-gds-ptrl-densities {&type-char}
&scop format-attr-gds-ptrl-densities  "X(21)"
&scop label-attr-gds-ptrl-densities   "Диапазон плотности"
&scop tooltip-attr-gds-ptrl-densities   "Диапазон плотности"
&scop user-can-edit-attr-gds-ptrl-densities  true
&scop output-display-attr-gds-ptrl-densities  true
&scop other-attr-gds-ptrl-densities "spr=gds-attr_gds-ptrl-densities"
&glob news-attr-gds-ptrl-densities true
&scop copy-attr-gds-ptrl-densities  false
&scop manual-edit-attr-gds-ptrl-densities  6
&scop batch-edit-attr-gds-ptrl-densities  6

/*длина (мм)*/
&glob type-attr-length-of {&type-int}
&glob format-attr-length-of  ">>>>>>>>9"
&glob label-attr-length-of   "Длина"
&glob tooltip-attr-length-of   "Длина"
&glob user-can-edit-attr-length-of  true
&glob output-display-attr-length-of  true
&glob other-attr-length-of  ""
&glob news-attr-length-of true
&glob copy-attr-length-of  true
&scop manual-edit-attr-length-of 3
&scop batch-edit-attr-length-of  3

/*ширина (мм)*/
&glob type-attr-width-of {&type-int}
&glob format-attr-width-of  ">>>>>>>>9"
&glob label-attr-width-of   "Ширина"
&glob tooltip-attr-width-of   "Ширина"
&glob user-can-edit-attr-width-of  true
&glob output-display-attr-width-of  true
&glob other-attr-width-of  ""
&glob news-attr-width-of true
&glob copy-attr-width-of  true
&scop manual-edit-attr-width-of 3
&scop batch-edit-attr-width-of  3

/*высота (мм)*/
&glob type-attr-height-of {&type-int}
&glob format-attr-height-of  ">>>>>>>>9"
&glob label-attr-height-of   "Высота"
&glob tooltip-attr-height-of   "Высота"
&glob user-can-edit-attr-height-of  true
&glob output-display-attr-height-of  true
&glob other-attr-height-of  ""
&glob news-attr-height-of true
&glob copy-attr-height-of  true
&scop manual-edit-attr-height-of 3
&scop batch-edit-attr-height-of  3

/*Количество в коробке*/
&glob type-attr-qnty-in-box {&type-int}
&glob format-attr-qnty-in-box  ">>>>>>>>9"
&glob label-attr-qnty-in-box   "Количество в коробке"
&glob tooltip-attr-qnty-in-box   "Количество в коробке"
&glob user-can-edit-attr-qnty-in-box  true
&glob output-display-attr-qnty-in-box  true
&glob other-attr-qnty-in-box  ""
&glob news-attr-qnty-in-box true
&glob copy-attr-qnty-in-box  true
&scop manual-edit-attr-qnty-in-box 4
&scop batch-edit-attr-qnty-in-box  4

/*Вес коробки (товар + коробка)*/
&glob type-attr-weight-box {&type-dec}
&glob format-attr-weight-box  ">>>>>>>>9.999"
&glob label-attr-weight-box   "Вес коробки (товар + коробка)"
&glob tooltip-attr-weight-box   "Вес коробки (товар + коробка)"
&glob user-can-edit-attr-weight-box  true
&glob output-display-attr-weight-box  true
&glob other-attr-weight-box  ""
&glob news-attr-weight-box true
&glob copy-attr-weight-box  true
&scop manual-edit-attr-weight-box 4
&scop batch-edit-attr-weight-box  4

/*Количество на палете*/
&glob type-attr-qnty-on-pallet {&type-int}
&glob format-attr-qnty-on-pallet  ">>>>>>>>9"
&glob label-attr-qnty-on-pallet   "Количество на палете"
&glob tooltip-attr-qnty-on-pallet   "Количество на палете"
&glob user-can-edit-attr-qnty-on-pallet  true
&glob output-display-attr-qnty-on-pallet  true
&glob other-attr-qnty-on-pallet  ""
&glob news-attr-qnty-on-pallet true
&glob copy-attr-qnty-on-pallet  true
&scop manual-edit-attr-qnty-on-pallet 4
&scop batch-edit-attr-qnty-on-pallet  4

/*Вес палеты (товар + коробка)*/
&glob type-attr-weight-of-pallet {&type-dec}
&glob format-attr-weight-of-pallet  ">>>>>>>>9.999"
&glob label-attr-weight-of-pallet   "Вес палеты (товар + коробка)"
&glob tooltip-attr-weight-of-pallet   "Вес палеты (товар + коробка)"
&glob user-can-edit-attr-weight-of-pallet  true
&glob output-display-attr-weight-of-pallet  true
&glob other-attr-weight-of-pallet  ""
&glob news-attr-weight-of-pallet true
&glob copy-attr-weight-of-pallet  true
&scop manual-edit-attr-weight-of-pallet 1
&scop batch-edit-attr-weight-of-pallet  1

/* Изображения */
&scop           type-attr-image-list {&type-char}
&scop         format-attr-image-list "X(75)"
&scop          label-attr-image-list "Изображения"
&scop        tooltip-attr-image-list "Изображения"
&scop  user-can-edit-attr-image-list false
&scop output-display-attr-image-list true
&scop          other-attr-image-list ""
&scop           news-attr-image-list true
&scop           copy-attr-image-list true
&scop    manual-edit-attr-image-list 0
&scop     batch-edit-attr-image-list 0

/* Доп. ед. изм. */
&scop type-attr-MercUnits {&type-char}
&scop format-attr-MercUnits  "X(100)"
&scop label-attr-MercUnits   "Дополнительные единицы измерения"
&scop tooltip-attr-MercUnits   "Дополнительные единицы измерения"
&scop user-can-edit-attr-MercUnits  false
&scop output-display-attr-MercUnits  false
&scop other-attr-MercUnits  ""
&scop news-attr-MercUnits true
&scop copy-attr-MercUnits  true
&scop manual-edit-attr-MercUnits 0
&scop batch-edit-attr-MercUnits  0

/*Признак весового товара */
&scop type-attr-weighed-gds {&type-log}
&glob format-attr-weighed-gds  "+/ "
&glob label-attr-weighed-gds   "Является весовым товаром"
&glob tooltip-attr-weighed-gds "Является весовым товаром"
&glob user-can-edit-attr-weighed-gds  false
&glob output-display-attr-weighed-gds true
&glob other-attr-weighed-gds ""
&glob news-attr-weighed-gds  true
&glob copy-attr-weighed-gds  true
&scop manual-edit-attr-weighed-gds 1
&scop batch-edit-attr-weighed-gds  1


/*Признак продажи 18+ */
&scop type-attr-IS18Plus {&type-int}
&scop format-attr-IS18Plus  ">9"
&scop label-attr-IS18Plus   "Наличие возрастных ограничений"
&scop tooltip-attr-IS18Plus "Наличие возрастных ограничений"
&glob user-can-edit-attr-IS18Plus  true
&glob output-display-attr-IS18Plus  true
&glob other-attr-IS18Plus  ""
&glob news-attr-IS18Plus true
&glob copy-attr-IS18Plus  true
&scop manual-edit-attr-IS18Plus 4
&scop batch-edit-attr-IS18Plus  4

/* Оплата баллами Семейная команда */
&scop type-attr-loyalty-gift {&type-int}
&scop format-attr-loyalty-gift  ">9"
&scop label-attr-loyalty-gift   "Оплата баллами Семейная команда"
&scop tooltip-attr-loyalty-gift "Оплата баллами Семейная команда"
&glob user-can-edit-attr-loyalty-gift  false
&glob output-display-attr-loyalty-gift  true
&glob other-attr-loyalty-gift  ""
&glob news-attr-loyalty-gift true
&glob copy-attr-loyalty-gift  true
&scop manual-edit-attr-loyalty-gift 4
&scop batch-edit-attr-loyalty-gift  4

/* сюда добавлять новые параметры атрибутов товаров */

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-copy-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-copy = ~{&copy-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure gds-attr-name :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :

    case p-code :
      &scop attr-code attr-gds-attr-lock
      {&attr-temp-full-code}
      &scop attr-code attr-alcohol-prod
      {&attr-temp-full-code}
      &scop attr-code attr-egais-name
      {&attr-temp-full-code}
      &scop attr-code attr-ptrl-without-rvs
      {&attr-temp-full-code}
      &scop attr-code attr-office-type
      {&attr-temp-full-code}
      &scop attr-code attr-mark-type
      {&attr-temp-full-code}
      &scop attr-code attr-emrc-type
      {&attr-temp-full-code}
      &scop attr-code attr-item-matter-mark
      {&attr-temp-full-code}
      &scop attr-code attr-type-method-calc
      {&attr-temp-full-code}
      &scop attr-code attr-cash-book-id
      {&attr-temp-full-code}
      &scop attr-code attr-oper-serv-id
      {&attr-temp-full-code}
      &scop attr-code attr-group-np
      {&attr-temp-full-code}
      &scop attr-code attr-is-loyalty-payment
      {&attr-temp-full-code}
      &scop attr-code attr-ban-bonus
      {&attr-temp-full-code}
      &scop attr-code attr-null-price
      {&attr-temp-full-code}
      &scop attr-code attr-fasovka
      {&attr-temp-full-code}
      &scop attr-code attr-time-coock
      {&attr-temp-full-code}     
      &scop attr-code attr-mark
      {&attr-temp-full-code}
      &scop attr-code attr-mercur_FGIS
      {&attr-temp-full-code}
      &scop attr-code attr-perishable
      {&attr-temp-full-code}
      &scop attr-code attr-production-only
      {&attr-temp-full-code}
      &scop attr-code attr-sum-grp-gl
      {&attr-temp-full-code}
      &scop attr-code attr-15x80
      {&attr-temp-full-code}
      &scop attr-code attr-8x50
      {&attr-temp-full-code}
      &scop attr-code attr-6x50
      {&attr-temp-full-code}
      &scop attr-code attr-calories
      {&attr-temp-full-code}
      &scop attr-code attr-protein
      {&attr-temp-full-code}
      &scop attr-code attr-fat
      {&attr-temp-full-code}
      &scop attr-code attr-carbohydrate
      {&attr-temp-full-code}
      &scop attr-code attr-calc-cal-rec
      {&attr-temp-full-code}
      &scop attr-code attr-cash-parts
      {&attr-temp-full-code}
      &scop attr-code attr-ptrl-as-good
      {&attr-temp-full-code}
      &scop attr-code attr-dflt-insalepr
      {&attr-temp-full-code}
      &scop attr-code attr-gds-ptrl-densities
      {&attr-temp-full-code}
      &scop attr-code attr-gds-CommodityCode
      {&attr-temp-full-code}
      &scop attr-code attr-gds-code-AIS
      {&attr-temp-full-code}      
      &scop attr-code attr-length-of
      {&attr-temp-full-code}
      &scop attr-code attr-width-of
      {&attr-temp-full-code}
      &scop attr-code attr-height-of
      {&attr-temp-full-code}
      &scop attr-code attr-qnty-in-box
      {&attr-temp-full-code}
      &scop attr-code attr-weight-box
      {&attr-temp-full-code}
      &scop attr-code attr-qnty-on-pallet
      {&attr-temp-full-code}
      &scop attr-code attr-weight-of-pallet
      {&attr-temp-full-code}
      &scop attr-code attr-fuel-type
      {&attr-temp-full-code}
      &scop attr-code attr-image-list
      {&attr-temp-full-code}
      &scop attr-code attr-MercUnits
      {&attr-temp-full-code}
      &scop attr-code attr-weighed-gds
      {&attr-temp-full-code}
      &scop attr-code attr-IS18Plus
      {&attr-temp-full-code}
      &scop attr-code attr-loyalty-gift
      {&attr-temp-full-code}
      /* сюда добавлять новые параметры атрибутов товаров */
      otherwise do:
        undo, return error substitute("неизвестный глобальный атрибут товара &1", p-code ).
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gds-attr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-gds-attr-lock
      {&attr-temp-code}
      &scop attr-code attr-alcohol-prod
      {&attr-temp-code}
      &scop attr-code attr-egais-name
      {&attr-temp-code}
      &scop attr-code attr-ptrl-without-rvs
      {&attr-temp-code}
      &scop attr-code attr-office-type
      {&attr-temp-code}
      &scop attr-code attr-mark-type
      {&attr-temp-code}      
      &scop attr-code attr-emrc-type
      {&attr-temp-code}      
      &scop attr-code attr-item-matter-mark
      {&attr-temp-code}
      &scop attr-code attr-type-method-calc
      {&attr-temp-code}
      &scop attr-code attr-cash-book-id
      {&attr-temp-code}
      &scop attr-code attr-oper-serv-id
      {&attr-temp-code}
      &scop attr-code attr-group-np
      {&attr-temp-code}
      &scop attr-code attr-is-loyalty-payment
      {&attr-temp-code}
      &scop attr-code attr-ban-bonus
      {&attr-temp-code}
      &scop attr-code attr-null-price
      {&attr-temp-code}
      &scop attr-code attr-fasovka
      {&attr-temp-code}
	  &scop attr-code attr-time-coock
      {&attr-temp-code}
      &scop attr-code attr-mark
      {&attr-temp-code}
      &scop attr-code attr-mercur_FGIS
      {&attr-temp-code}
      &scop attr-code attr-perishable
      {&attr-temp-code}
      &scop attr-code attr-production-only
      {&attr-temp-code}
      &scop attr-code attr-sum-grp-gl
      {&attr-temp-code}
      &scop attr-code attr-15x80
      {&attr-temp-code}
      &scop attr-code attr-8x50
      {&attr-temp-code}
      &scop attr-code attr-6x50
      {&attr-temp-code}
      &scop attr-code attr-calories
      {&attr-temp-code}
      &scop attr-code attr-protein
      {&attr-temp-code}
      &scop attr-code attr-fat
      {&attr-temp-code}
      &scop attr-code attr-carbohydrate
      {&attr-temp-code}
      &scop attr-code attr-calc-cal-rec
      {&attr-temp-code}
      &scop attr-code attr-cash-parts
      {&attr-temp-code}
      &scop attr-code attr-ptrl-as-good
      {&attr-temp-code}
      &scop attr-code attr-dflt-insalepr
      {&attr-temp-code}
      &scop attr-code attr-gds-ptrl-densities
      {&attr-temp-code}
      &scop attr-code attr-gds-CommodityCode
      {&attr-temp-code}    
      &scop attr-code attr-gds-code-AIS
      {&attr-temp-code}  
      &scop attr-code attr-length-of
      {&attr-temp-code}
      &scop attr-code attr-width-of
      {&attr-temp-code}
      &scop attr-code attr-height-of
      {&attr-temp-code}
      &scop attr-code attr-qnty-in-box
      {&attr-temp-code}
      &scop attr-code attr-weight-box
      {&attr-temp-code}
      &scop attr-code attr-qnty-on-pallet
      {&attr-temp-code}
      &scop attr-code attr-weight-of-pallet
      {&attr-temp-code}
      &scop attr-code attr-fuel-type
      {&attr-temp-code}
      &scop attr-code attr-image-list
      {&attr-temp-code}
      &scop attr-code attr-MercUnits
      {&attr-temp-code}
      &scop attr-code attr-weighed-gds
      {&attr-temp-code}
      &scop attr-code attr-IS18Plus
      {&attr-temp-code}
      &scop attr-code attr-loyalty-gift
      {&attr-temp-code}

      /* сюда добавлять новые параметры атрибутов товаров */
      otherwise do:
        undo, return error substitute("Неизвестный глобальный атрибут товара &1", p-code ).
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gds-attr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-gds-code as integer   no-undo .  /*  gds-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define output parameter p-value    as character no-undo .  /* значение атрибута */
  define output parameter p-type     as character no-undo .

  define buffer goods          for ub.goods.
  define buffer buf-goods-attr for ub.goods-attr.

  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .


    run gds-attr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-goods-attr no-lock where
                buf-goods-attr.attr-code = p-code
           and  buf-goods-attr.gds-code  = p-gds-code no-error .
   if avail buf-goods-attr then do:
    assign
    p-value = buf-goods-attr.attr-value.
   end.
   else do:
      find first goods where goods.gds-code eq p-gds-code no-lock no-error.
      if available goods
      then do:
         /* вернет ошибку если не известный атрибут группы */
         run ggoattr-value (input  goods.grp-code,
                            input  0,
                            input  "",
                            input  0,
                            input  p-code,
                            output p-value,
                            output p-type) no-error.
         if error-status:error
         then 
            p-value = if p-type = {&type-log} then "no":U else "".
     end.
     else 
        p-value = if p-type = {&type-log} then "no":U else "". 
     end.   
end.
end procedure.


procedure gds-attr-write :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define input parameter p-value    like ub.goods-attr.attr-value no-undo .

    define buffer buf_goods-attr for ub.goods-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gds-attr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_goods-attr exclusive-lock where
               buf_goods-attr.gds-code  = p-gds-code
          AND  buf_goods-attr.attr-code = p-code no-error .
    if not available buf_goods-attr then do:
      create buf_goods-attr .
      assign
        buf_goods-attr.gds-code  = p-gds-code
        buf_goods-attr.attr-code = p-code
        buf_goods-attr.attr-value = p-value no-error
      .
    end.
    ELSE
      buf_goods-attr.attr-value = p-value no-error.
    if error-status :error then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure gds-attr-EXIST :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .

    define buffer buf_goods-attr for ub.goods-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gds-attr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_goods-attr NO-lock where
               buf_goods-attr.gds-code  = p-gds-code
           AND buf_goods-attr.attr-code = p-code no-error .
    if available buf_goods-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure gds-attr-DELETE :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define output parameter p-DELETED  AS LOGICAL no-undo .

    define buffer buf_goods-attr for ub.goods-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gds-attr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_goods-attr exclusive-lock where
               buf_goods-attr.gds-code  = p-gds-code
           AND buf_goods-attr.attr-code = p-code no-error .
    if not available buf_goods-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
       delete buf_goods-attr.
      p-DELETED = YES.
    END.
  end.

end procedure.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gds-attr-copy-to :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-gds-code as integer   no-undo .  /*  gds-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define input  parameter p-bh       as handle no-undo .     /* буфер поле которого заполним */


  define buffer buf-goods-attr for ub.goods-attr.

  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define variable v-type           as character no-undo .


    run gds-attr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-goods-attr no-lock where
                buf-goods-attr.attr-code = p-code
           and  buf-goods-attr.gds-code  = p-gds-code no-error .
   if not p-bh:available then do:
     p-bh:buffer-create().
   end.
   if avail buf-goods-attr then do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = buf-goods-attr.attr-value.
   end.
   else do:
     assign
     p-bh:buffer-field("attr-value"):buffer-value = if v-type = {&type-log} then "no":U else "".
   end.
end.
end procedure.


procedure gds-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code attr-alcohol-prod
      {&attr-news-code}
      &scop attr-code attr-egais-name
      {&attr-news-code}
      &scop attr-code attr-ptrl-without-rvs
      {&attr-news-code}
      &scop attr-code attr-office-type
      {&attr-news-code}
      &scop attr-code attr-mark-type
      {&attr-news-code}
      &scop attr-code attr-emrc-type
      {&attr-news-code}
      &scop attr-code attr-item-matter-mark
      {&attr-news-code}
      &scop attr-code attr-type-method-calc
      {&attr-news-code}
      &scop attr-code attr-cash-book-id
      {&attr-news-code}
      &scop attr-code attr-oper-serv-id
      {&attr-news-code}
      &scop attr-code attr-group-np
      {&attr-news-code}
      &scop attr-code attr-is-loyalty-payment
      {&attr-news-code}
      &scop attr-code attr-ban-bonus
      {&attr-news-code}
      &scop attr-code attr-null-price
      {&attr-news-code}
      &scop attr-code attr-fasovka
      {&attr-news-code}
	  &scop attr-code attr-time-coock
      {&attr-news-code}
      &scop attr-code attr-mark
      {&attr-news-code}
      &scop attr-code attr-sum-grp-gl
      {&attr-news-code}
      &scop attr-code attr-mercur_FGIS
      {&attr-news-code}
      &scop attr-code attr-perishable
      {&attr-news-code}
      &scop attr-code attr-production-only
      {&attr-news-code}
      &scop attr-code attr-15x80
      {&attr-news-code}
      &scop attr-code attr-8x50
      {&attr-news-code}
      &scop attr-code attr-6x50
      {&attr-news-code}
      &scop attr-code attr-calories
      {&attr-news-code}
      &scop attr-code attr-protein
      {&attr-news-code}
      &scop attr-code attr-fat
      {&attr-news-code}
      &scop attr-code attr-carbohydrate
      {&attr-news-code}
      &scop attr-code attr-calc-cal-rec
      {&attr-news-code}
      &scop attr-code attr-cash-parts
      {&attr-news-code}
      &scop attr-code attr-ptrl-as-good
      {&attr-news-code}
      &scop attr-code attr-dflt-insalepr
      {&attr-news-code}
      &scop attr-code attr-gds-ptrl-densities
      {&attr-news-code}
      &scop attr-code attr-gds-CommodityCode
      {&attr-news-code}
      &scop attr-code attr-gds-code-AIS
      {&attr-news-code}
      &scop attr-code attr-length-of
      {&attr-news-code}
      &scop attr-code attr-width-of
      {&attr-news-code}
      &scop attr-code attr-height-of
      {&attr-news-code}
      &scop attr-code attr-qnty-in-box
      {&attr-news-code}
      &scop attr-code attr-weight-box
      {&attr-news-code}
      &scop attr-code attr-qnty-on-pallet
      {&attr-news-code}
      &scop attr-code attr-weight-of-pallet
      {&attr-news-code}
      &scop attr-code attr-fuel-type
      {&attr-news-code}
      &scop attr-code attr-image-list
      {&attr-news-code}
      &scop attr-code attr-MercUnits
      {&attr-news-code}
      &scop attr-code attr-weighed-gds
      {&attr-news-code}
      &scop attr-code attr-IS18Plus
      {&attr-news-code}
     &scop attr-code attr-loyalty-gift      
      {&attr-news-code}
      
      /* сюда добавлять новые параметры атрибутов товаров */
      otherwise do:
        undo, return error substitute("неизвестный глобальный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure gds-attr-copy :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-copy           as logical   no-undo . /* копируется при копировании товара - если включены соответ настройки */

    case p-code :
      &scop attr-code attr-alcohol-prod
      {&attr-copy-code}
      &scop attr-code attr-egais-name
      {&attr-copy-code}
      &scop attr-code attr-ptrl-without-rvs
      {&attr-copy-code}
      &scop attr-code attr-office-type
      {&attr-copy-code}
      &scop attr-code attr-mark-type
      {&attr-copy-code}
      &scop attr-code attr-emrc-type
      {&attr-copy-code}
      &scop attr-code attr-item-matter-mark
      {&attr-copy-code}
      &scop attr-code attr-type-method-calc
      {&attr-copy-code}
      &scop attr-code attr-cash-book-id
      {&attr-copy-code}
      &scop attr-code attr-oper-serv-id
      {&attr-copy-code}
      &scop attr-code attr-group-np
      {&attr-copy-code}
      &scop attr-code attr-is-loyalty-payment
      {&attr-copy-code}
      &scop attr-code attr-ban-bonus
      {&attr-copy-code}
      &scop attr-code attr-null-price
      {&attr-copy-code}
      &scop attr-code attr-fasovka
      {&attr-copy-code}
      &scop attr-code attr-time-coock
      {&attr-copy-code}
      &scop attr-code attr-mark
      {&attr-copy-code}
      &scop attr-code attr-sum-grp-gl
      {&attr-copy-code}
      &scop attr-code attr-mercur_FGIS
      {&attr-copy-code}
      &scop attr-code attr-perishable
      {&attr-copy-code}
      &scop attr-code attr-production-only
      {&attr-copy-code}
      &scop attr-code attr-15x80
      {&attr-copy-code}
      &scop attr-code attr-8x50
      {&attr-copy-code}
      &scop attr-code attr-6x50
      {&attr-copy-code}
      &scop attr-code attr-calories
      {&attr-copy-code}
      &scop attr-code attr-protein
      {&attr-copy-code}
      &scop attr-code attr-fat
      {&attr-copy-code}
      &scop attr-code attr-carbohydrate
      {&attr-copy-code}
      &scop attr-code attr-calc-cal-rec
      {&attr-copy-code}
      &scop attr-code attr-cash-parts
      {&attr-copy-code}
      &scop attr-code attr-ptrl-as-good
      {&attr-copy-code}
      &scop attr-code attr-dflt-insalepr
      {&attr-copy-code}
      &scop attr-code attr-gds-ptrl-densities
      {&attr-copy-code}
      &scop attr-code attr-gds-CommodityCode
      {&attr-copy-code}  
      &scop attr-code attr-gds-code-AIS
      {&attr-copy-code}    
      &scop attr-code attr-length-of
      {&attr-copy-code}
      &scop attr-code attr-width-of
      {&attr-copy-code}
      &scop attr-code attr-height-of
      {&attr-copy-code}
      &scop attr-code attr-qnty-in-box
      {&attr-copy-code}
      &scop attr-code attr-weight-box
      {&attr-copy-code}
      &scop attr-code attr-qnty-on-pallet
      {&attr-copy-code}
      &scop attr-code attr-weight-of-pallet
      {&attr-copy-code}
      &scop attr-code attr-fuel-type
      {&attr-copy-code}
      &scop attr-code attr-image-list
      {&attr-copy-code}
      &scop attr-code attr-MercUnits
      {&attr-copy-code}
      &scop attr-code attr-weighed-gds
      {&attr-copy-code}
      &scop attr-code attr-IS18Plus      
      {&attr-copy-code}
      &scop attr-code attr-loyalty-gift
      {&attr-copy-code}

      /* сюда добавлять новые параметры атрибутов товаров */
      otherwise do:
        undo, return error substitute("неизвестный глобальный атрибут товара &1", p-code) .
      end.
    end.
  end.
end procedure.


procedure gds-attr_check-ptrl-divis :
  define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  define buffer buf_goods for ub.goods.

  define variable v-is-petrolium as logical no-undo .
  define variable v-is-pieces    as logical no-undo .

  do
  on error undo, return error return-value
  :
    if p-mode = {&deletion} then do:
      p-correct = yes.
      return.
    end.
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                              , p-gds-code).
    end.
    { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-is-petrolium v-is-pieces no-error }
    if error-status:error then do:
      assign
        p-error-code =  substitute("&1 &2", error-status:get-message(1) , return-value )
      .
      return.
    end.
    if not v-is-petrolium and not p-code = {&attr-ptrl-as-good} then do:
      case p-code:
/*        when {&attr-is-gas} then do:                                                                    */
/*          assign                                                                                        */
/*            p-error-code = substitute("Товар-топливо типа ГАЗ должен иметь топливную единицу измерения")*/
/*          .                                                                                             */
/*        end.                                                                                            */
        when {&attr-ptrl-without-rvs} then do:
          assign
            p-error-code = substitute("Товар-топливо не требующий сверки должен иметь топливную единицу измерения")
          .
        end.
        /*when {&attr-ptrl-as-good} then do:
          assign
            p-error-code = substitute("ТНП продающийся через ТРК должен иметь топливную единицу измерения")
          .
        end.*/
      end case.
      return p-error-code.
    end.
    if v-is-pieces then do:
      case p-code:
/*        when {&attr-is-gas}  then do:                                                                 */
/*          assign                                                                                      */
/*            p-error-code = substitute("Товар-топливо типа ГАЗ должен иметь дробную единицу измерения")*/
/*          .                                                                                           */
/*        end.                                                                                          */
        when {&attr-ptrl-without-rvs}  then do:
          assign
            p-error-code = substitute("Товар-топливо не требующий сверки должен иметь дробную единицу измерения")
          .
        end.
        when {&attr-ptrl-as-good} then do:
          assign
            p-error-code = substitute("ТНП продающийся через ТРК должен иметь дробную единицу измерения ")
          .
        end.
      end case.
      return p-error-code.
    end.
    assign
    p-correct = yes.
  end.

end procedure. /* gds-attr_check-ptrl-divis */

procedure gds-attr_gds-ptrl-densities :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .

DEFINE VARIABLE v-value        as character no-undo .
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces    as logical no-undo .

define buffer buf_goods for ub.goods.

  do
  on error undo, return error
  :
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      message
        substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута", p-gds-code)
      view-as alert-box error.
      return.
    end.
    { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-is-petrolium v-is-pieces no-error }
    if error-status:error then do:
      message
        substitute("&1 &2", error-status:get-message(1) , return-value )
      view-as alert-box error.
      return.
    end.
    if not v-is-petrolium then do:
      message
        substitute("Товар-топливо должен иметь топливную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.
    if v-is-pieces then do:
      message
        substitute("Товар-топливо должен иметь дробную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.

    assign
    v-value = p-value.
    run ref/gdsptrdn.w (
                    input p-gds-code
                   ,input-output v-value
                   ) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* gds-attr_gds-ptrl-densities */

procedure gds-attr_check-office-type :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.
do
on error undo, return error return-value
:
  CASE p-mode:
    when {&add-def} then do:
     find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
      if not available buf_goods then do:
        return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                                , p-gds-code).
      end.
      if buf_goods.gds-type <> {&gds-office} and p-value <> {&attr-office-type_card-act}  then do:
        p-error-code = "Товар должен быть услугой".
      end.
      if lookup(p-value, {&prop-list-attr-office-type}) = 0 then do:
        p-error-code = "Значение атрибута должно быть одним из списка {&prop-list-attr-office-type}".
      end.
     
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.

procedure gds-attr_check-mark-type :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .
define variable MarkType as ibs.th.str.marking.Types no-undo.

define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.
do
on error undo, return error return-value
:
  CASE p-mode:
    when {&add-def} then do:
/*     find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .                                          */
/*      if not available buf_goods then do:                                                                                   */
/*        return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"*/
/*                                , p-gds-code).                                                                              */
/*      end.                                                                                                                  */
      MarkType = new ibs.th.str.marking.Types ().
      if MarkType:GetKeyIntDB(p-value) < 0 then do:
        p-error-code = "Неизвестное значение атрибута".
      end.
      delete object MarkType. 
     
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.

procedure gds-attr_check-emrc-type :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

define buffer buf_code for ub.code.
do
on error undo, return error return-value
:
  if   ( p-mode eq {&add-def} 
     or p-mode eq {&update})
     and p-value ne "" 
     
  then do:
     find first buf_code  where buf_code.parent = "EMC"
                            and buf_code.code   = p-value
     no-lock no-error .
     if not available buf_code then do:
        return error substitute("Нет такой группы в спрочнике ЕМЦ.").
     end.
      
  end.
end.
assign
p-correct = yes.
end procedure.


procedure gds-attr_check-item-matter-mark :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

do
on error undo, return error return-value
:
  CASE p-mode:
    when {&add-def} 
    or
    when {&update}
    then do:
      
      if    lookup(p-value, {&prop-list-attr-item-matter-mark}) = 0  
      then do:
         p-error-code =  "Значение атрибута должно быть одним из списка {&prop-list-attr-item-matter-mark}" .
      end.
     
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.

procedure gds-attr_check-type-method-calc :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

do
on error undo, return error return-value
:
  CASE p-mode:
    when {&add-def} 
    or
    when {&update}
    then do:
      
      if num-entries(p-value) <> 2 or 
         lookup(entry(1,p-value), {&prop-list-attr-type-method-calc}) = 0 or
         lookup(entry(2,p-value), "1,2") = 0   
      then do:
         p-error-code =  "Значение атрибута не соответствует допустимым значениям" .
      end.
     
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.

procedure gds-attr_check-cash-book-id :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

   define variable VValue as integer no-undo.
   do
   on error undo, return error return-value
   :
     CASE p-mode:
       when {&add-def} 
       or
       when {&update}
       then do:
          VValue = int64(p-value) no-error.
          if     p-value ne ""
             and VValue eq 0
        then
           p-error-code = "Значение не может быть 0".
        else do:
            find first cashbook where CashBook.id eq VValue no-lock no-error.
            if not available  cashbook
            then
               p-error-code = "Не существует кассоdая книга с номером " + string( VValue).
        end.
        if p-error-code <> "" then
           return p-error-code.
       end.
     END CASE.
   end.
   assign
   p-correct = yes.
end procedure.

procedure gds-attr_check-oper-serv-id :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

   define variable VValue as integer no-undo.
   do
   on error undo, return error return-value
   :
     CASE p-mode:
       when {&add-def} 
       or
       when {&update}
       then do:
          VValue = int64(p-value) no-error.
          if     p-value ne ""
             and VValue eq 0
        then
           p-error-code = "Значение не может быть 0".
        else do:
            find first operserv where operserv.id eq VValue no-lock no-error.
            if not available  operserv
            then
               p-error-code = "Не существует оператора с номером " + string( VValue).
        end.
        if p-error-code <> "" then
           return p-error-code.
       end.
     END CASE.
   end.
   assign
   p-correct = yes.
end procedure.

procedure gds-attr_check-group-np :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.

  define variable v-is-petrolium as logical no-undo .
  define variable v-is-pieces    as logical no-undo .

do
on error undo, return error return-value
:
  CASE p-mode:
    when {&add-def} then do:
     find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
      if not available buf_goods then do:
        return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                                , p-gds-code).
      end.
{ str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-is-petrolium v-is-pieces no-error }
    if error-status:error then do:
      message
        substitute("&1 &2", error-status:get-message(1) , return-value )
      view-as alert-box error.
      return.
    end.
    if not v-is-petrolium then do:
      message
        substitute("Товар-топливо должен иметь топливную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.
    if v-is-pieces then do:
      message
        substitute("Товар-топливо должен иметь дробную единицу измерения для задания диапазона плотности")
      view-as alert-box error.
      return.
    end.
     
     if p-error-code <> "" then
        return p-error-code.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.

procedure gds-attr_check-is-loyalty-payment :
define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
define input parameter p-value as character no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

define buffer buf_goods for ub.goods.
define buffer buf_gds-host-attr for ub.gds-host-attr.
do
on error undo, return error return-value
:
  CASE p-mode:
    when {&add-def} then do:
     find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
      if not (
              buf_goods.gds-type = {&gds-office}
              and
              buf_goods.unit-base = "{&abbr_rub}") then do:
        assign
        p-error-code = substitute("Перечисление в систему лояльности должно быть услугой,&1" +
                      "с единицей измерения равной единице измерения национальной валюты (&2)"
                      , {&new-line}
                      , "{&abbr_rub}"
                      ).
        return p-error-code.
      end.
    end.
  END CASE.
end.
assign
p-correct = yes.
end procedure.


procedure gds-attr_init-15x80 :
define input parameter p-gds-code as integer no-undo .
define output parameter p-attr-value as character no-undo .
define variable output-num-lines as integer no-undo init 1.
define variable v-value as character no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  if p-gds-code > 0 then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code  .
      p-attr-value = Break-n-line
        ( INPUT buf_goods.struct,
          INPUT right-trim(fill(string(80) + {&comma-char}, 15), {&comma-char}),
          OUTPUT output-num-lines
          ) .
  end.
end.

end procedure. /* gds-attr_init-15x80 */

procedure gds-glob-sum-grps :

define input parameter p-mode  as character no-undo .
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input-output parameter p-value as integer no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE rid-list as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.

  do
  on error undo, return error
  :
    find first buf_sum-grp no-lock where
               buf_sum-grp.grp-code = integer(p-value) no-error .
    if avail buf_sum-grp then do:
      assign
      rid-list = string(recid(buf_sum-grp))
      .
    end.
    if p-mode = {&lookup} then do:
    run ref/gds-sumgrp.p ( input this-procedure
                          ,input ""
                          ,input-output rid-list).
    end.
    else do:
      run ref/gds-sumgrp.p ( input this-procedure
                          ,input "b-sel"
                          ,input-output rid-list).
    end.
    if rid-list <> "":U then do:
      find first buf_sum-grp no-lock where
                 recid(buf_sum-grp) = integer(entry(1, rid-list)) no-error .
      if not avail buf_sum-grp then return error.

      assign
      p-value = buf_sum-grp.grp-code
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.

end procedure. /* gds-glob-sum-grps */

procedure gds-attr_init-8x50 :
define input parameter p-gds-code as integer no-undo .
define output parameter p-attr-value as character no-undo .
define variable output-num-lines as integer no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  if p-gds-code > 0 then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code  .
    p-attr-value = Break-n-line
      ( INPUT buf_goods.struct,
        INPUT right-trim(fill(string(50) + {&comma-char}, 8), {&comma-char}),
        OUTPUT output-num-lines
        ) .


  end.
end.

end procedure. /* gds-attr_init-8x50 */

procedure gds-attr_init-6x50 :
define input parameter p-gds-code as integer no-undo .
define output parameter p-attr-value as character no-undo .
define variable output-num-lines as integer no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  if p-gds-code > 0 then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = p-gds-code  .
    p-attr-value = Break-n-line
      ( INPUT buf_goods.struct,
        INPUT right-trim(fill(string(50) + {&comma-char}, 6), {&comma-char}),
        OUTPUT output-num-lines
        ) .


  end.
end.

end procedure. /* gds-attr_init-6x50 */

procedure gds-attr_check-can-energy-value :
  define input parameter p-gds-code like ub.goods-attr.gds-code     no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  /*может быть {&add-def} {&update} {&deletion}*/
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .

  define buffer buf_goods for ub.goods.

  define variable v-label as character no-undo .
  define variable v-tool-tip as character no-undo .
  define variable v-value as character no-undo .
  define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-mode = {&deletion} then do:
      p-correct = yes.
      return.
    end.
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                              , p-gds-code).
    end.
    /*найдем атрибут*/
    run  gds-attr-value in this-procedure (
                                            input buf_goods.gds-code
                                           ,input {&attr-calc-cal-rec}
                                           ,output v-value
                                           ,output v-type) .
    if logical(v-value) = no then do:
      assign
      p-correct = yes.
      return ''.
    end.
    else do:
      run gds-attr-tooltip in this-procedure ( input p-code
                                              ,output v-tool-tip
                                              ,output v-label) no-error.
      if error-status:error then do:
        v-label = p-code.
      end.
      assign
      p-error-code = substitute("Запрещено изменение атрибута &1&2" +
                    "на товаре &3 стоит флаг <Расчет энергетической ценности из основного рецепта>"
                    , v-label
                    , {&new-line}
                    , buf_goods.gds-code
                    ).

      return p-error-code.
    end.
  end.

end procedure. /* gds-attr_check-can-energy-value */



/*секция pop-up меню при ручном редактировании */

procedure gds-attr-manual-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-alcohol-prod
      {&attr-manual-edit-code}
      &scop attr-code attr-egais-name
      {&attr-manual-edit-code}
      &scop attr-code attr-ptrl-without-rvs
      {&attr-manual-edit-code}
      &scop attr-code attr-office-type
      {&attr-manual-edit-code}
      &scop attr-code attr-mark-type
      {&attr-manual-edit-code}
      &scop attr-code attr-emrc-type
      {&attr-manual-edit-code}
      
      &scop attr-code attr-item-matter-mark
      {&attr-manual-edit-code}
      &scop attr-code attr-type-method-calc
      {&attr-manual-edit-code}
      &scop attr-code attr-cash-book-id
      {&attr-manual-edit-code}
      &scop attr-code attr-oper-serv-id
      {&attr-manual-edit-code}
      &scop attr-code attr-group-np
      {&attr-manual-edit-code}
      &scop attr-code attr-is-loyalty-payment
      {&attr-manual-edit-code}
      &scop attr-code attr-ban-bonus
      {&attr-manual-edit-code}
      &scop attr-code attr-null-price
      {&attr-manual-edit-code}
      &scop attr-code attr-fasovka
      {&attr-manual-edit-code}
      &scop attr-code attr-time-coock
      {&attr-manual-edit-code}
      &scop attr-code attr-mercur_FGIS
      {&attr-manual-edit-code}
      &scop attr-code attr-perishable
      {&attr-manual-edit-code}
      &scop attr-code attr-production-only
      {&attr-manual-edit-code}
      &scop attr-code attr-mark
      {&attr-manual-edit-code}
      &scop attr-code attr-sum-grp-gl
      {&attr-manual-edit-code}
      &scop attr-code attr-15x80
      {&attr-manual-edit-code}
      &scop attr-code attr-8x50
      {&attr-manual-edit-code}
      &scop attr-code attr-6x50
      {&attr-manual-edit-code}
      &scop attr-code attr-calories
      {&attr-manual-edit-code}
      &scop attr-code attr-protein
      {&attr-manual-edit-code}
      &scop attr-code attr-fat
      {&attr-manual-edit-code}
      &scop attr-code attr-carbohydrate
      {&attr-manual-edit-code}
      &scop attr-code attr-calc-cal-rec
      {&attr-manual-edit-code}
      &scop attr-code attr-cash-parts
      {&attr-manual-edit-code}
      &scop attr-code attr-ptrl-as-good
      {&attr-manual-edit-code}
      &scop attr-code attr-dflt-insalepr
      {&attr-manual-edit-code}
      &scop attr-code attr-gds-ptrl-densities
      {&attr-manual-edit-code}
      &scop attr-code attr-gds-CommodityCode
      {&attr-manual-edit-code}
      &scop attr-code attr-gds-code-AIS
      {&attr-manual-edit-code}
      &scop attr-code attr-length-of
      {&attr-manual-edit-code}
      &scop attr-code attr-width-of
      {&attr-manual-edit-code}
      &scop attr-code attr-height-of
      {&attr-manual-edit-code}
      &scop attr-code attr-qnty-in-box
      {&attr-manual-edit-code}
      &scop attr-code attr-weight-box
      {&attr-manual-edit-code}
      &scop attr-code attr-qnty-on-pallet
      {&attr-manual-edit-code}
      &scop attr-code attr-weight-of-pallet
      {&attr-manual-edit-code}
      &scop attr-code attr-fuel-type
      {&attr-manual-edit-code}
      &scop attr-code attr-image-list
      {&attr-manual-edit-code}
      &scop attr-code attr-MercUnits
      {&attr-manual-edit-code}
      &scop attr-code attr-weighed-gds
      {&attr-manual-edit-code}
      &scop attr-code attr-IS18Plus          
      {&attr-manual-edit-code}
      &scop attr-code attr-loyalty-gift
      {&attr-manual-edit-code}

      /* сюда добавлять новые параметры атрибутов товаров */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure gds-attr-batch-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-alcohol-prod
      {&attr-batch-edit-code}
      &scop attr-code attr-egais-name
      {&attr-batch-edit-code}
      &scop attr-code attr-ptrl-without-rvs
      {&attr-batch-edit-code}
      &scop attr-code attr-office-type
      {&attr-batch-edit-code}
      &scop attr-code attr-mark-type
      {&attr-batch-edit-code}
      &scop attr-code attr-emrc-type
      {&attr-batch-edit-code}
      &scop attr-code attr-item-matter-mark
      {&attr-batch-edit-code}
      &scop attr-code attr-type-method-calc
      {&attr-batch-edit-code}
      &scop attr-code attr-cash-book-id
      {&attr-batch-edit-code}
      &scop attr-code attr-oper-serv-id
      {&attr-batch-edit-code}
      &scop attr-code attr-group-np
      {&attr-batch-edit-code}
      &scop attr-code attr-is-loyalty-payment
      {&attr-batch-edit-code}
      &scop attr-code attr-ban-bonus
      {&attr-batch-edit-code}
      &scop attr-code attr-null-price
      {&attr-batch-edit-code}
      &scop attr-code attr-fasovka
      {&attr-batch-edit-code}
	  &scop attr-code attr-time-coock
      {&attr-batch-edit-code}
      &scop attr-code attr-mark
      {&attr-batch-edit-code}
      &scop attr-code attr-sum-grp-gl
      {&attr-batch-edit-code}
      &scop attr-code attr-mercur_FGIS
      {&attr-batch-edit-code}
      &scop attr-code attr-perishable
      {&attr-batch-edit-code}
      &scop attr-code attr-production-only
      {&attr-batch-edit-code}
      &scop attr-code attr-calories
      {&attr-batch-edit-code}
      &scop attr-code attr-protein
      {&attr-batch-edit-code}
      &scop attr-code attr-fat
      {&attr-batch-edit-code}
      &scop attr-code attr-carbohydrate
      {&attr-batch-edit-code}
      &scop attr-code attr-calc-cal-rec
      {&attr-batch-edit-code}
      &scop attr-code attr-cash-parts
      {&attr-batch-edit-code}
      &scop attr-code attr-ptrl-as-good
      {&attr-batch-edit-code}
      &scop attr-code attr-dflt-insalepr
      {&attr-batch-edit-code}
      &scop attr-code attr-gds-ptrl-densities
      {&attr-batch-edit-code}
      &scop attr-code attr-gds-CommodityCode
      {&attr-batch-edit-code}
      &scop attr-code attr-gds-code-AIS
      {&attr-batch-edit-code}
      &scop attr-code attr-length-of
      {&attr-batch-edit-code}
      &scop attr-code attr-width-of
      {&attr-batch-edit-code}
      &scop attr-code attr-height-of
      {&attr-batch-edit-code}
      &scop attr-code attr-qnty-in-box
      {&attr-batch-edit-code}
      &scop attr-code attr-weight-box
      {&attr-batch-edit-code}
      &scop attr-code attr-qnty-on-pallet
      {&attr-batch-edit-code}
      &scop attr-code attr-weight-of-pallet
      {&attr-batch-edit-code}
      &scop attr-code attr-fuel-type
      {&attr-batch-edit-code}
      &scop attr-code attr-image-list
      {&attr-batch-edit-code}
      &scop attr-code attr-MercUnits
      {&attr-batch-edit-code}
      &scop attr-code attr-weighed-gds
      {&attr-batch-edit-code}

      /* сюда добавлять новые параметры атрибутов товаров */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара &1", p-code ).
      end.
    end.
  end.
end procedure.

/* ################## */
/* атрибуты бар-кода */

/* Код тары для сканер-весов NCR */
&scop type-attr-taracode-bc {&type-int}
&scop format-attr-taracode-bc  "99"
&scop label-attr-taracode-bc   "Код тары для сканер-весов NCR"
&scop tooltip-attr-taracode-bc "Код тары для сканер-весов NCR"
/*только по объекту*/
&scop range-attr-taracode-bc  ~{&bef-object-int~}
&scop user-can-edit-attr-taracode-bc  true
&scop output-display-attr-taracode-bc  true
&scop other-attr-taracode-bc  "spr=bc-oattr_taracode-bc":U
&scop copy-attr-taracode-bc  true
&scop manual-edit-attr-taracode-bc  2
&scop batch-edit-attr-taracode-bc  2


/* сюда добавлять новые параметры атрибутов  bar-code */

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-range = ~{&range-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-copy-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-copy = ~{&copy-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure bc-oattr_name :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-range          as integer   no-undo . /*области действия атрибута*/
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :

    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-code :
      &scop attr-code attr-taracode-bc
      {&attr-temp-full-code}


      /* сюда добавлять новые параметры атрибутов бар-кодов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure bc-oattr_tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.



    case p-code :
      &scop attr-code attr-taracode-bc
      {&attr-temp-code}

      /* сюда добавлять новые параметры атрибутов бар-кодов */
      otherwise do:
        undo, return error substitute("Неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure bc-oattr_value :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-b-code   as integer   no-undo .  /*  b-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-value    as character no-undo .  /* значение атрибута */
  define output parameter p-type     as character no-undo .

  define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr.

  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .


  run bc-oattr_name in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  Find first  buf_bar-code-obj-attr no-lock where
              buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
          and  buf_bar-code-obj-attr.b-code  = p-b-code no-error .
  if avail buf_bar-code-obj-attr then do:
    assign
    p-value = buf_bar-code-obj-attr.attr-value.
  end.
  else do:
    assign
    p-value = if p-type = {&type-log} then "no":U else "".
  end.
end.
end procedure.

procedure bc-oattr_write :

  do
  on error undo, return error
  :
    define input parameter p-b-code   like ub.bar-code-obj-attr.b-code   no-undo .
    define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer   no-undo .
    define input parameter p-value    like ub.bar-code-obj-attr.attr-value no-undo .

    define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .
    define buffer buf_bar-code      for ub.bar-code.

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run bc-oattr_name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_bar-code-obj-attr exclusive-lock where
              buf_bar-code-obj-attr.b-code  = p-b-code
          AND  buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
    no-error .
    if not available buf_bar-code-obj-attr then do:
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = p-b-code no-error.
      if not available buf_bar-code then do:
        undo, return error substitute("Не найден бар-код &1, для которого сохраняется атрибут &2"
                                                , p-b-code
                                                , p-code) .
      end.
      create buf_bar-code-obj-attr .
      assign
      buf_bar-code-obj-attr.b-code  = p-b-code
      buf_bar-code-obj-attr.attr-code = p-code + (if p-obj-type <> '' then  ({&delim-par} + p-obj-type + {&delim-par} + string(p-obj-code)) else '')
      buf_bar-code-obj-attr.attr-value = p-value
      buf_bar-code-obj-attr.gds-code = buf_bar-code.gds-code
      .
    end.
    ELSE
    assign
    buf_bar-code-obj-attr.attr-value = p-value no-error
    .

  end.

end procedure.


procedure bc-oattr_EXIST :

  do
  on error undo, return error
  :
    define input parameter p-b-code   like ub.bar-code-obj-attr.b-code   no-undo .
    define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer   no-undo .
    define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .

    define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run bc-oattr_name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_bar-code-obj-attr no-lock where
              buf_bar-code-obj-attr.b-code  = p-b-code
          AND  buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
    no-error .
    if available buf_bar-code-obj-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure bc-oattr_DELETE :

  do
  on error undo, return error
  :
    define input parameter p-b-code   like ub.bar-code-obj-attr.b-code    no-undo .
    define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer   no-undo .
    define output parameter p-DELETED  AS LOGICAL no-undo .

    define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run bc-oattr_name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_bar-code-obj-attr no-lock where
              buf_bar-code-obj-attr.b-code  = p-b-code
          AND  buf_bar-code-obj-attr.attr-code = p-code
          and buf_bar-code-obj-attr.obj-type = p-obj-type
          and buf_bar-code-obj-attr.obj-code = p-obj-code
    no-error .
    if not available buf_bar-code-obj-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
       delete buf_bar-code-obj-attr.
      p-DELETED = YES.
    END.
  end.

end procedure.


/*секция pop-up меню при ручном редактировании */

procedure bc-oattr_manual-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-taracode-bc
      {&attr-manual-edit-code}

      /* сюда добавлять новые параметры атрибутов бар-кодов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure bc-oattr_batch-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-taracode-bc
      {&attr-batch-edit-code}

      /* сюда добавлять новые параметры атрибутов бар-кодов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут бар-кода &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure bc-oattr_taracode-bc :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-b-code like ub.bar-code-obj-attr.b-code no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .


DEFINE VARIABLE rid-list as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable par-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-new-value as character no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer bc_units for ub.units.

  do
  on error undo, return error return-value
  :
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = p-b-code no-error.
    if not available buf_bar-code then do:
      message
      substitute("Не найден бар-код &1, для которого вводится атрибут!", p-b-code)
      view-as alert-box error.
      undo, return error.
    end.
    find first buf_goods no-lock where
              buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if not available buf_goods then do:
      message
      substitute("Не найден товар &1, для бар-кода которого вводится атрибут!", buf_bar-code.gds-code)
      view-as alert-box error.
      undo, return error.
    end.
    find first buf_units no-lock where
              buf_units.unit-name = buf_goods.unit-base no-error.
    if not available buf_units then do:
      message
      substitute("Не найдена осн. ед.изм &1 товара &2, для бар-кода которого вводится атрибут!"
                  , buf_goods.unit-base
                 , buf_bar-code.gds-code)
      view-as alert-box error.
      undo, return error.
    end.
    find first bc_units no-lock where
              bc_units.unit-name = buf_bar-code.unit-cli no-error.
    if not available bc_units then do:
      message
      substitute("Не найдена изм &1 бар-кода &2, для которого вводится атрибут!"
                  , buf_bar-code.unit-cli
                 , buf_bar-code.b-code)
      view-as alert-box error.
      undo, return error.
    end.
    if not (LOOKUP( {&weight}, buf_units.type ) > 0
    and (LOOKUP( {&divisional}, bc_units.type ) > 0
          or
          LOOKUP( {&weight}, bc_units.type ) > 0)
          )
    then do:
      message
      substitute("Атрибут можно ввести только для весового или взвешиваемого бар-кода!"
                  , buf_bar-code.unit-cli
                 , buf_bar-code.b-code)
      view-as alert-box error.
      undo, return error.
    end.
    if buf_bar-code.unit-cli begins "№" then do:
      v-new-value = substring(buf_bar-code.unit-cli, 2).
    end.
    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
    /*найдем dflt-cd для объекта*/

    run adm/shattri.p (
      input "get":U
      ,input p-obj-type
      ,input p-obj-code
      ,input  {&attr-cd-sending}
      ,input  "dflt-cd":U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    IF not error-status:error then
    assign
    dflt-cd = v-value-character .
    if v-new-value <> '' then do:
      /*упрощенное создание атрибута на основе мнемонического соглашения - если ед.изм начинается на № то оставшиеся две циыры - это код тары*/
      find first buf_cash-desk-attr no-lock where
                buf_cash-desk-attr.obj-code = p-obj-code
          and buf_cash-desk-attr.cash-num = 0
          and buf_cash-desk-attr.pos-type = dflt-cd
          and buf_cash-desk-attr.attr-code = ('tara-ref':U  + {&delim-par} + v-new-value)
          and buf_cash-desk-attr.db-num  = v-obj-db-num  no-error .
      if available buf_cash-desk-attr then do:
        assign
        p-value = string(integer(entry(2, buf_cash-desk-attr.attr-code, {&delim-par}) ), "99")
        p-setted = yes
        .
        return.
      end.
    end.

    find first buf_cash-desk-attr no-lock where
              buf_cash-desk-attr.obj-code = p-obj-code
         and  buf_cash-desk-attr.cash-num = 0
         and  buf_cash-desk-attr.pos-type = dflt-cd
         and buf_cash-desk-attr.attr-code = ('tara-ref':U  + {&delim-par} + p-value)
         and buf_cash-desk-attr.db-num  = v-obj-db-num  no-error .

    if avail buf_cash-desk-attr then do:
      assign
      rid-list = string(recid(buf_cash-desk-attr))
      .
    end.
    run ref/ncrtarac.w ( input parparentproc
                    ,input ? /*p-db-num*/
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input ? /*p-pos-type */
                    ,input ? /*p-cash-num*/
                    ,input "b-sel"
                    ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_cash-desk-attr no-lock where
                 recid(buf_cash-desk-attr) = integer(entry(1, rid-list)) no-error .
      if not avail buf_cash-desk-attr then return error.
      assign
      p-value = string(integer(entry(2, buf_cash-desk-attr.attr-code, {&delim-par}) ), "99")
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.

end procedure. /* bc-oattr-taracode */



/* ################## */
/* атрибуты касс */
/*при изменении надо менять pie на 16.0 08070701.p !!!!!!*/


/* настройки кассы MAGIA  */
&scop label-cda-MAGIA-XML_operative "Оперативные параметры"
&scop tooltip-cda-MAGIA-XML_operative "Оперативные параметры POS MAGIA-XML"
&scop user-can-edit-cda-MAGIA-XML_operative true
&scop output-display-cda-MAGIA-XML_operative true
&scop user-can-edit-list-cda-MAGIA-XML_operative '~
true'
&scop output-display-list-cda-MAGIA-XML_operative '~
true'
&scop other-cda-MAGIA-XML_operative 'spr=last-check-date-time'
&scop prop-type-list-cda-MAGIA-XML_operative 'character'
&scop prop-format-list-cda-MAGIA-XML_operative 'X(19)'
&scop prop-label-list-cda-MAGIA-XML_operative '~
Дата и время последнего принятого чека/док-та'
&scop manual-edit-cda-MAGIA-XML_operative  '1'
&scop batch-edit-cda-MAGIA-XML_operative  0
&scop news-cda-MAGIA-XML_operative '~
false'
&scop from-gbd-cda-MAGIA-XML_operative '~
false'
&scop from-ubd-cda-MAGIA-XML_operative '~
true'
&scop hist-cda-MAGIA-XML_operative '~
false'
&scop send-param-cda-MAGIA-XML_operative  '~
false'
/**/

/* настройки кассы IBM-XML  */
&scop label-cda-IBM-XML_operative "Оперативные параметры"
&scop tooltip-cda-IBM-XML_operative "Оперативные параметры POS IBM-XML"
&scop user-can-edit-cda-IBM-XML_operative true
&scop output-display-cda-IBM-XML_operative true
&scop user-can-edit-list-cda-IBM-XML_operative '~
true~
,true~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false'
&scop output-display-list-cda-IBM-XML_operative '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true'
&scop other-cda-IBM-XML_operative 'spr=cd-attr-last-check-params,cd-attr-last-report-params,,'
&scop prop-type-list-cda-IBM-XML_operative 'character,character,character,character,integer,character,character,character,character,character,character,character,character,character'
&scop prop-format-list-cda-IBM-XML_operative 'X(19)|X(19)|X(255)|X(255)|9|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)|X(9)'
&scop prop-label-list-cda-IBM-XML_operative '~
Параметры последнего принятого чека/док-та~
,Параметры последнего принятого кассового отчета~
,Версия кассовой программы~
,Версия ПО «Коннектор»~
,Признак исполнения кассы~
,ФФД версия~
,ККТ версия~
,Схема интеграции ККТ~
,Время последнего опроса касс~
,Дата последнего опроса касс~
,Быстрый ответ ГИСМТ~
,Таймаут ожидания~
,Таймаут ожидания проверки ГИСМТ~
,Таймаут  открытия соединения ГИСМТ'
&scop manual-edit-cda-IBM-XML_operative  '1,1,0,0,0,0,0,0,0,0,0,0,0,0'
&scop batch-edit-cda-IBM-XML_operative   '0,0,0,0,0,0,0,0,0,0,0,0,0,0'
&scop news-cda-IBM-XML_operative '~
false~
,false~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true'
&scop from-gbd-cda-IBM-XML_operative '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false'
&scop from-ubd-cda-IBM-XML_operative '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true'
&scop hist-cda-IBM-XML_operative '~
false~
,false~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true'
&scop send-param-cda-IBM-XML_operative  '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false'
/**/

&scop label-cda-IBM-XML_general "Общие настройки"
&scop tooltip-cda-IBM-XML_general "Общие настройки POS IBM-XML"
&scop user-can-edit-cda-IBM-XML_general true
&scop output-display-cda-IBM-XML_general true
&scop user-can-edit-list-cda-IBM-XML_general '~
true~
,true'
&scop output-display-list-cda-IBM-XML_general '~
true~
,true'
&scop other-cda-IBM-XML_general '':U
&scop prop-type-list-cda-IBM-XML_general 'logical,logical'
&scop prop-format-list-cda-IBM-XML_general '+/|+/'
&scop prop-label-list-cda-IBM-XML_general '~
Использовать КБО~
,Работает с EasyFuel'
&scop manual-edit-cda-IBM-XML_general  '2,2'
&scop batch-edit-cda-IBM-XML_general  0,0
&scop news-cda-IBM-XML_general '~
true~
,true'
&scop from-gbd-cda-IBM-XML_general '~
true~
,true'
&scop from-ubd-cda-IBM-XML_general '~
true~
,true'
&scop hist-cda-IBM-XML_general '~
true~
,true'
&scop send-param-cda-IBM-XML_general  '~
true~
,true'
/**/


/* настройки кассы AUTOTANK  */
&scop label-cda-AUTOTANK_operative "Оперативные параметры"
&scop tooltip-cda-AUTOTANK_operative "Оперативные параметры POS AUTOTANK"
&scop user-can-edit-cda-AUTOTANK_operative true
&scop output-display-cda-AUTOTANK_operative true
&scop user-can-edit-list-cda-AUTOTANK_operative '~
true~
,true~
,false~
,false~
,false'
&scop output-display-list-cda-AUTOTANK_operative '~
true~
,true~
,true~
,true~
,true'
&scop other-cda-AUTOTANK_operative 'spr=cd-attr-last-check-params,cd-attr-last-report-params,'
&scop prop-type-list-cda-AUTOTANK_operative 'character,character,character,character,integer'
&scop prop-format-list-cda-AUTOTANK_operative 'X(19)|X(19)|X(255)|X(255)|X(9)'
&scop prop-label-list-cda-AUTOTANK_operative '~
Параметры последнего принятого чека/док-та~
,Параметры последнего принятого кассового отчета~
,Версия кассовой программы~
,Версия ПО «Коннектор»~
,Признак исполнения кассы'
&scop manual-edit-cda-AUTOTANK_operative  '1,1,0,0,0,'
&scop batch-edit-cda-AUTOTANK_operative  '0,0,0,0,0'
&scop news-cda-AUTOTANK_operative '~
false~
,false~
,true~
,true~
,true'
&scop from-gbd-cda-AUTOTANK_operative '~
false~
,false~
,false~
,false~
,false'
&scop from-ubd-cda-AUTOTANK_operative '~
true~
,true~
,true~
,true~
,true'
&scop hist-cda-AUTOTANK_operative '~
false~
,false~
,true~
,true~
,true'
&scop send-param-cda-AUTOTANK_operative  '~
false~
,false~
,false~
,false~
,false'
/**/



/* Оперативные MARIA*/
&scop label-cda-MARIA_operative "Оперативные параметры"
&scop tooltip-cda-MARIA_operative "Оперативные параметры POS MARIA"
&scop user-can-edit-cda-MARIA_operative true
&scop output-display-cda-MARIA_operative true
&scop user-can-edit-list-cda-MARIA_operative '~
true~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'
&scop output-display-list-cda-MARIA_operative '~
true~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'
&scop other-cda-MARIA_operative 'spr=cd-attr-last-check-maria,,,,,,,,,':U
&scop prop-type-list-cda-MARIA_operative 'character,character,integer,integer,logical,integer,integer,logical,integer,integer,logical'
&scop prop-format-list-cda-MARIA_operative 'X(19)|X(19)|>>>>9|>>>>9|+/|9|9|+/|>>9|>>9|+/'
&scop prop-label-list-cda-MARIA_operative '~
Параметры последнего принятого чека~
,Актуальность данных кассы MARIA~
,Текущее количество товаров на кассе~
,Максимальный plu на кассе в данный момент~
,Признак на кассе есть товары не отправленные на кассу~
,Текущее количество нефтепродуктов на кассе~
,Максимальное значение plu топлива из содержащихся на кассе в данный момент~
,Признак на кассе есть топлива не отправленные на кассу~
,Текущее количество клиентов на кассе~
,Максимальное значение clu из содержащихся на кассе в данный момент~
,Признак на кассе есть клиентов не отправленные на кассу~
'
&scop manual-edit-cda-MARIA_operative  '1,0,0,0,0,0,0,0,0,0'
&scop batch-edit-cda-MARIA_operative  0
&scop news-cda-MARIA_operative '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'
&scop from-gbd-cda-MARIA_operative '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'
&scop from-ubd-cda-MARIA_operative '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop hist-cda-MARIA_operative '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'
&scop send-param-cda-MARIA_operative  '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'
/**/


/* Общие MARIA*/
&scop label-cda-MARIA_general "Общие параметры"
&scop tooltip-cda-MARIA_general "Общие параметры POS MARIA"
&scop user-can-edit-cda-MARIA_general true
&scop output-display-cda-MARIA_general true
&scop user-can-edit-list-cda-MARIA_general '~
true~
,true~
,true~
,true~
'
&scop output-display-list-cda-MARIA_general '~
true~
,true~
,true~
,true~
'
&scop other-cda-MARIA_general 'check=cd-attr_check-marketer,cd-attr_check-marketer,cd-attr_check-marketer,cd-attr_check-marketer':U
&scop prop-type-list-cda-MARIA_general 'integer,integer,integer,integer'
&scop prop-format-list-cda-MARIA_general '>>>>9|>>>>9|9|>>9'
&scop prop-label-list-cda-MARIA_general '~
Максимальное количество товаров на кассе~
,Начало диапазона plu для топлив на кассе~
,Размер диапазона plu для топлив на кассе~
,Максимальное количество клиентов на кассе~
'
&scop manual-edit-cda-MARIA_general  '2,2,2,2'
&scop batch-edit-cda-MARIA_general  0
&scop news-cda-MARIA_general '~
true~
,true~
,true~
,true~
'
&scop from-gbd-cda-MARIA_general '~
false~
,false~
,false~
,false~
'
&scop from-ubd-cda-MARIA_general '~
true~
,true~
,true~
,true~
'
&scop hist-cda-MARIA_general '~
true~
,true~
,true~
,true~
'
&scop send-param-cda-MARIA_general  '~
false~
,false~
,false~
,false~
'
/**/

/* Периодические задания кассы MARIA */
&scop type-cd-attr-periodic-tasks {&type-char}
&scop format-cd-attr-periodic-tasks "X(255)"
&scop label-cd-attr-periodic-tasks "Периодические задания кассы MARIA"
&scop tooltip-cd-attr-periodic-tasks "Периодические задания кассы MARIA"
&scop user-can-edit-cd-attr-periodic-tasks false
&scop output-display-cd-attr-periodic-tasks false
&scop other-cd-attr-periodic-tasks 'spr=cd-attr-periodic-tasks/cd=MARIA':u
&scop news-cd-attr-periodic-tasks false
&scop from-gbd-cd-attr-periodic-tasks true
&scop from-ubd-cd-attr-periodic-tasks true
&scop hist-cd-attr-periodic-tasks true
&scop manual-edit-cd-attr-periodic-tasks 0
&scop batch-edit-cd-attr-periodic-tasks  0
&scop send-param-cd-attr-periodic-tasks  true

/* настройки кассы INFOKIOSK  */
&scop label-cda-INFOKIOSK_operative "Оперативные параметры"
&scop tooltip-cda-INFOKIOSK_operative "Оперативные параметры INFOKIOSK"
&scop user-can-edit-cda-INFOKIOSK_operative false
&scop output-display-cda-INFOKIOSK_operative true
&scop user-can-edit-list-cda-INFOKIOSK_operative '~
false~
,false~
'
&scop output-display-list-cda-INFOKIOSK_operative '~
true~
,true~
'
&scop other-cda-INFOKIOSK_operative '':U
&scop prop-type-list-cda-INFOKIOSK_operative 'character,character'
&scop prop-format-list-cda-INFOKIOSK_operative 'X(32)|X(32)'
&scop prop-label-list-cda-INFOKIOSK_operative '~
Последнее изменение справочника групп товаров~
,Последнее изменение справочника шкал~
'
&scop manual-edit-cda-INFOKIOSK_operative  '1,1'
&scop batch-edit-cda-INFOKIOSK_operative  0
&scop news-cda-INFOKIOSK_operative '~
true~
,true~
'
&scop from-gbd-cda-INFOKIOSK_operative '~
false~
,false~
'
&scop from-ubd-cda-INFOKIOSK_operative '~
true~
,true~
'
&scop hist-cda-INFOKIOSK_operative '~
true~
,true~
'
&scop send-param-cda-INFOKIOSK_operative  '~
false~
,false~
'
/**/

/* Общие NCR-GM*/
&scop label-cda-NCR-GM_general "Общие параметры"
&scop tooltip-cda-NCR-GM_general "Общие параметры POS NCR-GM"
&scop user-can-edit-cda-NCR-GM_general true
&scop output-display-cda-NCR-GM_general true
&scop user-can-edit-list-cda-NCR-GM_general '~
true~
,true~
'
&scop output-display-list-cda-NCR-GM_general '~
true~
,true~
'
&scop other-cda-NCR-GM_general 'copy=,yes/auto=,2/send=,yes/compl-root=,yes/spr=,cd-attr-spr-tara-ref/display=,cd-attr-di-tara-ref':U
&scop prop-type-list-cda-NCR-GM_general 'decimal,character'
&scop prop-format-list-cda-NCR-GM_general '>>>>9.99|>>>>9.99'
&scop prop-label-list-cda-NCR-GM_general '~
Сообщение на кассе при превышении порогового значения суммы чека~
,Соответствие кодов тары весам тары для сканер-весов NCR~
'
&scop manual-edit-cda-NCR-GM_general  '1,1'
&scop batch-edit-cda-NCR-GM_general  0
&scop news-cda-NCR-GM_general '~
true~
,true~
'
&scop from-gbd-cda-NCR-GM_general '~
true~
,true~
'
&scop from-ubd-cda-NCR-GM_general '~
true~
,true~
'
&scop hist-cda-NCR-GM_general '~
true~
,true~
'
&scop send-param-cda-NCR-GM_general  '~
true~
,true~
'
/**/

/* Общие NCR-AS-R*/
&scop label-cda-NCR-AS-R_general "Общие параметры"
&scop tooltip-cda-NCR-AS-R_general "Общие параметры POS NCR-AS-R"
&scop user-can-edit-cda-NCR-AS-R_general true
&scop output-display-cda-NCR-AS-R_general true
&scop user-can-edit-list-cda-NCR-AS-R_general '~
true~
,true~
'
&scop output-display-list-cda-NCR-AS-R_general '~
true~
,true~
'
&scop other-cda-NCR-AS-R_general 'copy=yes/auto=2/send=yes/compl-root=yes/spr=cd-attr-spr-tara-ref/display=cd-attr-di-tara-ref':U
&scop prop-type-list-cda-NCR-AS-R_general 'decimal,character'
&scop prop-format-list-cda-NCR-AS-R_general '>>>>9.99|>>>>9.99'
&scop prop-label-list-cda-NCR-AS-R_general '~
Сообщение на кассе при превышении порогового значения суммы чека~
,Соответствие кодов тары весам тары для сканер-весов NCR~
'
&scop manual-edit-cda-NCR-AS-R_general  '1,1'
&scop batch-edit-cda-NCR-AS-R_general  0
&scop news-cda-NCR-AS-R_general '~
true~
,true~
'
&scop from-gbd-cda-NCR-AS-R_general '~
true~
,true~
'
&scop from-ubd-cda-NCR-AS-R_general '~
true~
,true~
'
&scop hist-cda-NCR-AS-R_general '~
true~
,true~
'
&scop send-param-cda-NCR-AS-R_general  '~
true~
,true~
'



&scop label-cda-IBS-TH_main "Основные настройки"
&scop tooltip-cda-IBS-TH_main "Основные настройки POS IBS-TH"
&scop user-can-edit-cda-IBS-TH_main true
&scop output-display-cda-IBS-TH_main true
&scop user-can-edit-list-cda-IBS-TH_main '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop output-display-list-cda-IBS-TH_main '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop other-cda-IBS-TH_main 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U
&scop prop-type-list-cda-IBS-TH_main 'integer,integer,integer,integer,integer,integer,integer'
&scop prop-format-list-cda-IBS-TH_main '9|>>9|9|9|9|9|9'
&scop prop-label-list-cda-IBS-TH_main '~
Работа со сменами~
,Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1)~
,Обязателен продавец~
,Разрешена ручная скидка~
,Уровень логирования~
,Обнулять счетчик наличности при Z-отчете~
,Разрешена коррекция кол-ва~
'
&scop manual-edit-cda-IBS-TH_main  '1,1,1,1,1,1,1'
&scop batch-edit-cda-IBS-TH_main  0
&scop news-cda-IBS-TH_main '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop from-gbd-cda-IBS-TH_main '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop from-ubd-cda-IBS-TH_main '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop hist-cda-IBS-TH_main '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop send-param-cda-IBS-TH_main  '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
'

&scop label-cda-IBS-TH_devices "Работа с устройствами"
&scop tooltip-cda-IBS-TH_devices "Работа с устройствами POS IBS-TH"
&scop user-can-edit-cda-IBS-TH_devices true
&scop output-display-cda-IBS-TH_devices true
&scop user-can-edit-list-cda-IBS-TH_devices '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop output-display-list-cda-IBS-TH_devices '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop other-cda-IBS-TH_devices 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U
&scop prop-type-list-cda-IBS-TH_devices 'integer,integer,integer,integer,integer,decimal,integer,integer,character,character,character,character,character,character'
&scop prop-format-list-cda-IBS-TH_devices '9|9|9|>>9|9|9|>>>,>>>,>>9.99|9|X(40)|X(20)|X(15)|X(12)|X(15)|X(5)|X(10)|X(16)'
&scop prop-label-list-cda-IBS-TH_devices '~
Подключать ДЯ~
,Тип подключения ДЯ~
,Порт подключения ДЯ~
,Кол-во имп. подключения ДЯ~
,Работа с открытым ДЯ~
,Предел наличности ДЯ~
,Подключать кардридер~
,Подключать дисплей покупателя~
,Текст рекламы на дисплее покупателя~
,Тип клавиатуры~
,Раскладка клавиатуры~
,Система безналичных платежей~
,Тип дисплея покупателя~
,Порт дисплея покупателя~
,Тип системы видеонаблюдения~
,Адрес/порт системы видеонаблюдения~
'
&scop manual-edit-cda-IBS-TH_devices  '2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2'
&scop batch-edit-cda-IBS-TH_devices  0
&scop news-cda-IBS-TH_devices '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop from-gbd-cda-IBS-TH_devices '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop from-ubd-cda-IBS-TH_devices '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop hist-cda-IBS-TH_devices '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop send-param-cda-IBS-TH_devices  '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'
/**/



&scop label-cda-IBS-TH_fisreg "Настройки для ФР"
&scop tooltip-cda-IBS-TH_fisreg "Настройки POS IBS-TH для фискального регистратора"
&scop user-can-edit-cda-IBS-TH_fisreg true
&scop output-display-cda-IBS-TH_fisreg true
&scop user-can-edit-list-cda-IBS-TH_fisreg '~
true~
,true~
,true~
,true~
,true~
'
&scop output-display-list-cda-IBS-TH_fisreg '~
true~
,true~
,true~
,true~
,true~
'
&scop other-cda-IBS-TH_fisreg 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U
&scop prop-type-list-cda-IBS-TH_fisreg 'integer,character,character,integer,character'
&scop prop-format-list-cda-IBS-TH_fisreg '>>>|X(255)|X(122)|9|X(4)|'
&scop prop-label-list-cda-IBS-TH_fisreg '~
Логический уровень датчика ДЯ в открытом состоянии~
,Типы кассовых платежей<->коды оплаты ФР~
,Наименования типов оплат ФР~
,Отрезание чеков~
,ФР подключен к~
'
&scop manual-edit-cda-IBS-TH_fisreg  '3,3,3,3,3'
&scop batch-edit-cda-IBS-TH_fisreg  0
&scop news-cda-IBS-TH_fisreg '~
true~
,true~
,true~
,true~
,true~
'
&scop from-gbd-cda-IBS-TH_fisreg '~
true~
,true~
,true~
,true~
,true~
'
&scop from-ubd-cda-IBS-TH_fisreg '~
true~
,true~
,true~
,true~
,true~
'
&scop hist-cda-IBS-TH_fisreg '~
true~
,true~
,true~
,true~
,true~
'
&scop send-param-cda-IBS-TH_fisreg  '~
false~
,false~
,false~
,false~
,false~
'

&scop label-cda-IBS-TH_rec-print "Настройки чеков"
&scop tooltip-cda-IBS-TH_rec-print "Настройки POS IBS-TH для чеков"
&scop user-can-edit-cda-IBS-TH_rec-print true
&scop output-display-cda-IBS-TH_rec-print true
&scop user-can-edit-list-cda-IBS-TH_rec-print '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop output-display-list-cda-IBS-TH_rec-print '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop other-cda-IBS-TH_rec-print 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U
&scop prop-type-list-cda-IBS-TH_rec-print 'decimal,character,character,integer,character,decimal,integer,integer'
&scop prop-format-list-cda-IBS-TH_rec-print '>>>,>>>,>>9.99|X(120)|X(220)|9|X(8)|->>9.99|9|9'
&scop prop-label-list-cda-IBS-TH_rec-print '~
Макс.сумма чека~
,Рекламный текст~
,Строки клише~
,Печатать код товара~
,Тип округления суммы чека~
,Коэфф. типа округления суммы чека~
,Печатать слип отлож.чека~
,Печатать отлож.чек на доп.принтере~
'
&scop manual-edit-cda-IBS-TH_rec-print  '4,4,4,4,4,4,4,4'
&scop batch-edit-cda-IBS-TH_rec-print  0
&scop news-cda-IBS-TH_rec-print '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop from-gbd-cda-IBS-TH_rec-print '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop from-ubd-cda-IBS-TH_rec-print '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop hist-cda-IBS-TH_rec-print '~
true~
,true~
,true~
,true~
,true~
,true~
,true~
,true~
'
&scop send-param-cda-IBS-TH_rec-print  '~
false~
,false~
,false~
,false~
,false~
,false~
,false~
,false~
'


&scop label-cda-IBS-TH_interface "Настройки интерфейса"
&scop tooltip-cda-IBS-TH_interface "Настройки POS IBS-TH для интерфейса"
&scop user-can-edit-cda-IBS-TH_interface true
&scop output-display-cda-IBS-TH_interface true
&scop user-can-edit-list-cda-IBS-TH_interface '~
true~
,true~'
&scop output-display-list-cda-IBS-TH_interface '~
true~
,true~
'
&scop other-cda-IBS-TH_interface 'sprlevel=cd/spr=ref\cda-29.w/display=ref\cda-29.w':U
&scop prop-type-list-cda-IBS-TH_interface 'character,character'
&scop prop-format-list-cda-IBS-TH_interface 'X(120)|X(15)'
&scop prop-label-list-cda-IBS-TH_interface '~
Тип интерфейса~
,Раскладка~
'
&scop manual-edit-cda-IBS-TH_interface  '5,5'
&scop batch-edit-cda-IBS-TH_interface  0
&scop news-cda-IBS-TH_interface '~
true~
,true~
'
&scop from-gbd-cda-IBS-TH_interface '~
true~
,true~
'
&scop from-ubd-cda-IBS-TH_interface '~
true~
,true~
'
&scop hist-cda-IBS-TH_interface '~
true~
,true~
'
&scop send-param-cda-IBS-TH_interface  '~
false~
,false~
'

&scop label-cda-ibs-th-mob_main "Основные настройки"
&scop tooltip-cda-ibs-th-mob_main "Основные настройки POS IBS-TH-MOB"
&scop user-can-edit-cda-ibs-th-mob_main true
&scop output-display-cda-ibs-th-mob_main true
&scop user-can-edit-list-cda-ibs-th-mob_main '~
true~
,true~
'
&scop output-display-list-cda-ibs-th-mob_main '~
true~
,true~
'
&scop other-cda-ibs-th-mob_main 'sprlevel=cd/spr=ref\cda-31.w/display=ref\cda-31.w':U
&scop prop-type-list-cda-ibs-th-mob_main 'integer,character'
&scop prop-format-list-cda-ibs-th-mob_main '9|X(40)'
&scop prop-label-list-cda-ibs-th-mob_main '~
,Обязателен продавец~
,Тип POS, с которого брать скидки~
'
&scop manual-edit-cda-ibs-th-mob_main  '1,1'
&scop batch-edit-cda-ibs-th-mob_main  0
&scop news-cda-ibs-th-mob_main '~
true~
,true~
'
&scop from-gbd-cda-ibs-th-mob_main '~
true~
,true~
'
&scop from-ubd-cda-ibs-th-mob_main '~
true~
,true~
'
&scop hist-cda-ibs-th-mob_main '~
true~
,true~
'
&scop send-param-cda-ibs-th-mob_main  '~
false~
,false~
'

&scop label-cda-IBS-TH-MOB_rec-print "Настройки чеков"
&scop tooltip-cda-IBS-TH-MOB_rec-print "Настройки POS IBS-TH-MOB для чеков"
&scop user-can-edit-cda-IBS-TH-MOB_rec-print true
&scop output-display-cda-IBS-TH-MOB_rec-print true
&scop user-can-edit-list-cda-IBS-TH-MOB_rec-print '~
true~
,true~
'
&scop output-display-list-cda-IBS-TH-MOB_rec-print '~
true~
,true~
'
&scop other-cda-IBS-TH-MOB_rec-print 'sprlevel=cd/spr=ref\cda-31.w/display=ref\cda-31.w':U
&scop prop-type-list-cda-IBS-TH-MOB_rec-print 'integer,integer'
&scop prop-format-list-cda-IBS-TH-MOB_rec-print '9|9'
&scop prop-label-list-cda-IBS-TH-MOB_rec-print '~
,Печатать слип отлож.чека~
,Печатать отлож.чек на доп.принтере~
'
&scop manual-edit-cda-IBS-TH-MOB_rec-print  '2,2'
&scop batch-edit-cda-IBS-TH-MOB_rec-print  0
&scop news-cda-IBS-TH-MOB_rec-print '~
true~
,true~
'
&scop from-gbd-cda-IBS-TH-MOB_rec-print '~
true~
,true~
'
&scop from-ubd-cda-IBS-TH-MOB_rec-print '~
true~
,true~
'
&scop hist-cda-IBS-TH-MOB_rec-print '~
true~
,true~
'
&scop send-param-cda-IBS-TH-MOB_rec-print  '~
false~
,false~
'

/*при изменении надо менять pie на 16.0 08070701.p !!!!!!*/



/* сюда добавлять новые параметры атрибутов касс */

/* ------------------------------------------------------------------- */

&scop section-temp-code ~
  when ~{&~{&section-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&section-code~}~} ~
    p-label = ~{&label-~{&section-code~}~} ~
    p-label = p-label + ~
    (if p-code = '':U then '':U else (":" + entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&prop-label-list-~{&section-code~}~}))) ~
    p-tooltip = ~
    (if p-code = '':U then '':U ~
     else (entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ),'~{&prop-tooltip-list-~{&section-code~}~}'))) no-error. ~
  end.



&scop section-temp-full-code ~
  when ~{&~{&section-code~}~} then do: ~
    if p-code <> '' AND lookup(p-code, ~{&prop-list-~{&section-code~}~} ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ). ~
    assign ~
    p-label = ~{&label-~{&section-code~}~} ~
    p-label  = p-label + ~
               (if p-code = '':U  ~
                then   '' ~
                else (":" + entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&prop-label-list-~{&section-code~}~})))  ~
    p-format = (if p-code = '' ~
                then ~{&prop-format-list-~{&section-code~}~} ~
                else entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&prop-format-list-~{&section-code~}~}, "|")) ~
    p-type   = (if p-code = '':U  ~
                then   ~{&prop-type-list-~{&section-code~}~} ~
                else entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&prop-type-list-~{&section-code~}~}))  ~
    p-user-can-edit  = (if p-code = '':U  ~
                        then  ~{&user-can-edit-~{&section-code~}~} ~
                        else logical(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&user-can-edit-list-~{&section-code~}~})))  ~
    p-output-display = (if p-code = '':U  ~
                       then ~{&output-display-~{&section-code~}~} ~
                       else logical(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&output-display-list-~{&section-code~}~})))  ~
    p-other = ~{&other-~{&section-code~}~}  ~
    p-prop-list = ~{&prop-list-~{&section-code~}~}  ~
    . ~
  end.

&scop section-news-code ~
  when ~{&~{&section-code~}~} then do: ~
    if lookup(p-code, ~{&prop-list-~{&section-code~}~} ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ). ~
    assign ~
    p-news = logical(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ),~{&news-~{&section-code~}~} ~)) ~
    p-from-gbd = logical(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ),~{&from-gbd-~{&section-code~}~} ~)) ~
    p-from-ubd = logical(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ),~{&from-ubd-~{&section-code~}~} ~)) ~
    no-error. ~
  end.

&scop section-hist-code ~
  when ~{&~{&section-code~}~} then do: ~
    if p-code <> '' AND lookup(p-code, ~{&prop-list-~{&section-code~}~} ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ). ~
    assign ~
    p-hist = logical(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ),~{&hist-~{&section-code~}~} ~)) ~
    no-error. ~
  end.


&scop section-manual-edit-code ~
when ~{&~{&section-code~}~} then do: ~
  if p-code <> '' AND lookup(p-code, ~{&prop-list-~{&section-code~}~} ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ). ~
  assign ~
  p-section-num = integer(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&manual-edit-~{&section-code~}~})). ~
end.

&scop section-batch-edit-code ~
when ~{&~{&section-code~}~} then do: ~
  if p-code <> '' AND lookup(p-code, ~{&prop-list-~{&section-code~}~} ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ). ~
  assign ~
  p-section-num = integer(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ), ~{&batch-edit-~{&section-code~}~})). ~
end.


&scop section-send-param-code ~
  when ~{&~{&section-code~}~} then do: ~
    if lookup(p-code, ~{&prop-list-~{&section-code~}~} ) = 0 then undo, return error substitute("неизвестный атрибут/настройка кассы &1", p-code ). ~
    assign ~
    p-send-param = logical(entry(lookup(p-code, ~{&prop-list-~{&section-code~}~} ),~{&send-param-~{&section-code~}~} ~)) ~
    no-error. ~
  end.




procedure cd-attr-code :

  do
  on error undo, return error
  :
    define input  parameter p-ucode          as character no-undo . /* код секции */
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    define output parameter p-prop-list      as character no-undo . /*список членов секции*/

    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-ucode :
      &scop section-code cda-MAGIA-XML_operative
      {&section-temp-full-code}
      &scop section-code cda-IBM-XML_operative
      {&section-temp-full-code}
      &scop section-code cda-IBM-XML_general
      {&section-temp-full-code}
      &scop section-code cda-AUTOTANK_operative
      {&section-temp-full-code}
      &scop section-code cda-MARIA_operative
      {&section-temp-full-code}
      &scop section-code cda-MARIA_general
      {&section-temp-full-code}
      &scop section-code cda-INFOKIOSK_operative
      {&section-temp-full-code}
      &scop section-code cda-NCR-GM_general
      {&section-temp-full-code}
      &scop section-code cda-NCR-AS-R_general
      {&section-temp-full-code}
      &scop section-code cda-IBS-TH_main
      {&section-temp-full-code}
      &scop section-code cda-IBS-TH_devices
      {&section-temp-full-code}
      &scop section-code cda-IBS-TH_fisreg
      {&section-temp-full-code}
      &scop section-code cda-IBS-TH_rec-print
      {&section-temp-full-code}
      &scop section-code cda-IBS-TH_interface
      {&section-temp-full-code}
      &scop section-code cda-IBS-TH-MOB_main
      {&section-temp-full-code}
      &scop section-code cda-IBS-TH-MOB_rec-print
      {&section-temp-full-code}


      /* сюда добавлять новые параметры атрибутов касс  */
      otherwise do:
        undo, return error substitute("неизвестная секция настроек кассы &1", p-ucode ).
      end.
    end.
    return ''.
  end.
end procedure.

procedure cd-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-ucode    as character no-undo .
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

   if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-ucode :
      &scop section-code cda-MAGIA-XML_operative
      {&section-temp-code}
      &scop section-code cda-IBM-XML_operative
      {&section-temp-code}
      &scop section-code cda-IBM-XML_general
      {&section-temp-code}
      &scop section-code cda-AUTOTANK_operative
      {&section-temp-code}
      &scop section-code cda-MARIA_operative
      {&section-temp-code}
      &scop section-code cda-MARIA_general
      {&section-temp-code}
      &scop section-code cda-INFOKIOSK_operative
      {&section-temp-code}
      &scop section-code cda-NCR-GM_general
      {&section-temp-code}
      &scop section-code cda-NCR-AS-R_general
      {&section-temp-code}
      &scop section-code cda-IBS-TH_main
      {&section-temp-code}
      &scop section-code cda-IBS-TH_devices
      {&section-temp-code}
      &scop section-code cda-IBS-TH_fisreg
      {&section-temp-code}
      &scop section-code cda-IBS-TH_rec-print
      {&section-temp-code}
      &scop section-code cda-IBS-TH_interface
      {&section-temp-code}
      &scop section-code cda-IBS-TH-MOB_main
      {&section-temp-code}
      &scop section-code cda-IBS-TH-MOB_rec-print
      {&section-temp-code}


      /* сюда добавлять новые параметры атрибутов касс */
      otherwise do:
        undo, return error substitute("неизвестная секция настроек кассы &1", p-ucode ).
      end.
    end.
    return ''.
  end.

end procedure.


procedure cd-attr-value :

  do
  on error undo, return error
  :
    define input  parameter p-db-num   like ub.cash-desk-attr.db-num        no-undo .
    define input  parameter p-obj-code like ub.cash-desk-attr.obj-code      no-undo .
    define input  parameter p-pos-type like ub.cash-desk-attr.pos-type      no-undo .
    define input  parameter p-cash-num like ub.cash-desk-attr.cash-num      no-undo .
    define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code       no-undo .
    define input  parameter p-code     like ub.cash-desk-attr.attr-code      no-undo .
    define output parameter p-character like ub.cash-desk-attr.attr-value-character  no-undo .
    define output parameter p-date      like ub.cash-desk-attr.attr-value-date       no-undo .
    define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal    no-undo .
    define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer    no-undo .
    define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical    no-undo .

    define output parameter p-type     as character no-undo .

    define buffer buf_cash-desk-attr for {&db-name}.cash-desk-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .

    assign
    v-ucode = p-ucode
    v-code = p-code
    .
    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    run cd-attr-code in this-procedure
      (input  p-ucode         /* p-ucode           */
      ,input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ,output v-prop-list
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_cash-desk-attr no-lock
      where buf_cash-desk-attr.db-num    = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error .
    if avail buf_cash-desk-attr then do:
      assign
        p-character =  buf_cash-desk-attr.attr-value-character
        p-date      =  buf_cash-desk-attr.attr-value-date
        p-decimal   =  buf_cash-desk-attr.attr-value-decimal
        p-integer   =  buf_cash-desk-attr.attr-value-integer
        p-logical   =  buf_cash-desk-attr.attr-value-logical
        p-type      =  buf_cash-desk-attr.attr-value-type.
      .
    end.
  end.

end procedure.


procedure cd-attr-write :

  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define input parameter p-character like ub.cash-desk-attr.attr-value-character  no-undo .
    define input parameter p-date      like ub.cash-desk-attr.attr-value-date       no-undo .
    define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal    no-undo .
    define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer    no-undo .
    define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical    no-undo .


    define buffer buf_cash-desk-attr for {&db-name}.cash-desk-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-dop            as character no-undo .
    define variable v-prop-value-list as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .

    assign
    v-ucode = p-ucode
    v-code = p-code
    .


    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    run cd-attr-code in this-procedure
      (input  p-ucode          /* p-ucode           */
      ,input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ,output v-prop-list      /* p-prop-list*/
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_cash-desk-attr exclusive-lock
      where buf_cash-desk-attr.db-num  = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error .

    if not available buf_cash-desk-attr then do:
      create buf_cash-desk-attr .
      assign
      buf_cash-desk-attr.db-num    = p-db-num
      buf_cash-desk-attr.obj-code  = p-obj-code
      buf_cash-desk-attr.pos-type  = p-pos-type
      buf_cash-desk-attr.cash-num  = p-cash-num
      buf_cash-desk-attr.upper-attr-code = v-ucode
      buf_cash-desk-attr.attr-code = v-code
      buf_cash-desk-attr.attr-value-type = v-type
      .
    end.
    CASE buf_cash-desk-attr.attr-value-type:
      when {&abl-datatype-character} then do:
        assign
        buf_cash-desk-attr.attr-value-character = p-character
        .
      end.
      when {&abl-datatype-date} then do:
        assign
        buf_cash-desk-attr.attr-value-date = p-date
        .
      end.
      when {&abl-datatype-decimal} then do:
        assign
        buf_cash-desk-attr.attr-value-decimal = p-decimal
        .
      end.
      when {&abl-datatype-integer} then do:
        assign
        buf_cash-desk-attr.attr-value-integer = p-integer
      .
    end.
      when {&abl-datatype-logical} then do:
    assign
        buf_cash-desk-attr.attr-value-logical = p-logical
    .
      end.
    end case.
    release buf_cash-desk-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure cd-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_cash-desk-attr for {&db-name}.cash-desk-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .

    assign
    v-ucode = p-ucode
    v-code = p-code
    .


    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.


    run cd-attr-code in this-procedure
      (input  p-ucode          /* p-ucode           */
      ,input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ,output v-prop-list
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_cash-desk-attr exclusive-lock
      where buf_cash-desk-attr.db-num  = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error .

    if  available buf_cash-desk-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure cd-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .

    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_cash-desk-attr for {&db-name}.cash-desk-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .
    define variable v-ucode as character no-undo .
    define variable v-code as character no-undo .

    assign
    v-ucode = p-ucode
    v-code = p-code
    .


    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    run cd-attr-code in this-procedure
      (input  p-ucode          /* p-ucode           */
      ,input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ,output v-prop-list
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-desk-attr exclusive-lock
      where buf_cash-desk-attr.db-num  = p-db-num
        and buf_cash-desk-attr.obj-code  = p-obj-code
        and buf_cash-desk-attr.pos-type  = p-pos-type
        and buf_cash-desk-attr.cash-num  = p-cash-num
        and buf_cash-desk-attr.upper-attr-code = v-ucode
        and buf_cash-desk-attr.attr-code = v-code
      no-error NO-WAIT.
    if not available buf_cash-desk-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-desk-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure cd-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-ucode          as character no-undo . /* код секции */
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */
    define output parameter p-from-gbd       as logical   no-undo . /* редактируется в ГБД если касса УБД */
    define output parameter p-from-ubd       as logical   no-undo . /* редактируется в УБД если касса УБД */

    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-ucode :
      &scop section-code cda-MAGIA-XML_operative
      {&section-news-code}
      &scop section-code cda-IBM-XML_operative
      {&section-news-code}
      &scop section-code cda-IBM-XML_general
      {&section-news-code}
      &scop section-code cda-AUTOTANK_operative
      {&section-news-code}
      &scop section-code cda-MARIA_operative
      {&section-news-code}
      &scop section-code cda-MARIA_general
      {&section-news-code}
      &scop section-code cda-INFOKIOSK_operative
      {&section-news-code}
      &scop section-code cda-NCR-GM_general
      {&section-news-code}
      &scop section-code cda-NCR-AS-R_general
      {&section-news-code}
      &scop section-code cda-IBS-TH_main
      {&section-news-code}
      &scop section-code cda-IBS-TH_devices
      {&section-news-code}
      &scop section-code cda-IBS-TH_fisreg
      {&section-news-code}
      &scop section-code cda-IBS-TH_rec-print
      {&section-news-code}
      &scop section-code cda-IBS-TH_interface
      {&section-news-code}
      &scop section-code cda-IBS-TH-MOB_main
      {&section-news-code}
      &scop section-code cda-IBS-TH-MOB_rec-print
      {&section-news-code}

      /* сюда добавлять новые параметры атрибутов касс */

      otherwise do:
        p-news = no.
        p-from-ubd = yes.
      end.
    end.
    return ''.
  end.
end procedure.


procedure cd-attr-hist :

  do
  on error undo, return error
  :
    define input  parameter p-ucode          as character no-undo . /* код секции */
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-hist           as logical   no-undo . /* ходит в историю */

    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-ucode :
      &scop section-code cda-MAGIA-XML_operative
      {&section-hist-code}
      &scop section-code cda-IBM-XML_operative
      {&v-hist-code}
      &scop section-code cda-IBM-XML_general
      {&section-hist-code}
      &scop section-code cda-AUTOTANK_operative
      {&v-hist-code}
      &scop section-code cda-MARIA_operative
      {&section-hist-code}
      &scop section-code cda-MARIA_general
      {&section-hist-code}
      &scop section-code cda-INFOKIOSK_operative
      {&section-hist-code}
      &scop section-code cda-NCR-GM_general
      {&section-hist-code}
      &scop section-code cda-NCR-AS-R_general
      {&section-hist-code}
      &scop section-code cda-IBS-TH_main
      {&section-hist-code}
      &scop section-code cda-IBS-TH_devices
      {&section-hist-code}
      &scop section-code cda-IBS-TH_fisreg
      {&section-hist-code}
      &scop section-code cda-IBS-TH_rec-print
      {&section-hist-code}
      &scop section-code cda-IBS-TH_interface
      {&section-hist-code}
      &scop section-code cda-IBS-TH-MOB_main
      {&section-hist-code}
      &scop section-code cda-IBS-TH-MOB_rec-print
      {&section-hist-code}

      /* сюда добавлять новые параметры атрибутов касс */

      otherwise do:
        p-hist = no.
      end.
    end.
    return ''.
  end.
end procedure.


procedure cd-attr-parse-date-time-proc :

  define input  parameter p-string       as character no-undo .
  define output parameter p-time         as integer   no-undo .
  define output parameter p-return-value as date      no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-date as date.
    define variable v-shift as integer no-undo .

    if index(p-string, "-":U) = 0
    or NOT (length(p-string) = 10
            or
            length(p-string) = 19)
    then do:
      return error.
    end.
    assign
      v-date =  date(
              int( substr( p-string, 6, 2 ) ) ,
              int( substr( p-string, 9, 2 ) ),
              int( substr( p-string, 1, 4 ) )
                )
    no-error .
    if error-status:error
    then do:
      return error.
    end.
    if index(p-string, ":":U) = 0
    or not (
            length(p-string) = 19
            or
            length(p-string) = 8
            )
    then do:
      return error.
    end.
    if length(p-string) = 19 then v-shift = 11.
    assign
    p-time =  int( substr( p-string, v-shift + 1, 2 ) ) * 3600 +
              int( substr( p-string, v-shift + 4, 2 ) ) * 60  +
              int( substr( p-string, v-shift + 7, 2) )
    no-error .
    if error-status:error then do:
      return error.
    end.
    assign
      p-return-value = v-date
    .
  end.

end procedure. /* cd-attr-parse-date-time-proc */

procedure last-check-date-time :

  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-value as character no-undo .
  define variable v-codes as character no-undo .
  define variable v-labels as character no-undo .
  define variable v-date as date no-undo .
  define variable v-time as integer no-undo .
  define variable v-date2 as date no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-ok as logical no-undo .


  do
  on error undo, return error
  :

    assign
      v-value = p-character
    .
    run cd-attr-parse-date-time-proc in this-procedure
      (input  v-value
      ,output v-time
      ,output v-date
      ) no-error .

    run gbl/d-time.w (
                    input "Введите дату и время последнего полученного чека по данной кассе"
                   ,input ?
                   ,input 1 /*одна дата и время с секундами*/
                   ,input-output v-date
                   ,input-output v-date2
                   ,input-output v-time
                   ,input-output v-time2
                   ,output v-ok
                   ) no-error .

    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             {&space-char}  +  string(v-time, "HH:MM:SS":U).
    if
    v-ok and
    p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.

end procedure. /* gds-obj-std-disc */


procedure cd-attr-cd-datetostring-proc :

  define input  parameter p-date         as date      no-undo .
  define output parameter p-return-value as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-return-value = string(YEAR(p-date), "9999":U) + "-":U +
                       string(Month(p-date), "99":U) + "-":U +
                       string(DAY(p-date), "99":U)
    .
  end.

end procedure. /* cd-attr-cd-datetostring-proc */

procedure cd-attr-last-report-params :

  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .

  define output parameter p-setted as logical no-undo .

  define variable v-value as character no-undo .
  define variable v-codes as character no-undo .
  define variable v-labels as character no-undo .
  define variable v-date as date no-undo .
  define variable v-time as integer no-undo .
  define variable v-date2 as date no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-shift-num as integer no-undo .
  define variable v-shift-num2 as integer no-undo .
  define variable v-z-count as integer no-undo .
  define variable v-z-count2 as integer no-undo .
  define variable v-chk-num as integer no-undo .
  define variable v-chk-num2 as integer no-undo .
  define variable v-ok as logical no-undo .


  do
  on error undo, return error
  :
    assign
    v-value = p-character
    v-shift-num = (if num-entries(v-value, {&space-char}) > 2
                   then integer(entry(3, v-value, {&space-char}  ))
                   else 0)
    .
    run cd-attr-parse-date-time-proc in this-procedure
      (input  substring(v-value, 1 , 19)
      ,output v-time
      ,output v-date
      ) no-error .

    run str/lastchkd.w (
                    input "Введите параметры последнего полученного отчета по данной кассе"
                   ,input ?
                   ,input 1 /*одна дата и время с секундами*/
                   ,input "report"
                   ,input-output v-date
                   ,input-output v-date2
                   ,input-output v-time
                   ,input-output v-time2
                   ,input-output v-shift-num
                   ,input-output v-shift-num2
                   ,input-output v-z-count
                   ,input-output v-z-count2
                   ,input-output v-chk-num
                   ,input-output v-chk-num2
                   ,output v-ok
                   )  .

    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             {&space-char}  +  string(v-time, "HH:MM:SS":U) +
             {&space-char} + string(v-shift-num) 

             .
    if v-ok and
    p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.

end procedure. /* cd-attr-last-report-params */

procedure cd-attr-last-check-params :

  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .

  define output parameter p-setted as logical no-undo .

  define variable v-value as character no-undo .
  define variable v-codes as character no-undo .
  define variable v-labels as character no-undo .
  define variable v-date as date no-undo .
  define variable v-time as integer no-undo .
  define variable v-date2 as date no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-shift-num as integer no-undo .
  define variable v-shift-num2 as integer no-undo .
  define variable v-z-count as integer no-undo .
  define variable v-z-count2 as integer no-undo .
  define variable v-chk-num as integer no-undo .
  define variable v-chk-num2 as integer no-undo .
  define variable v-ok as logical no-undo .


  do
  on error undo, return error
  :

    assign
    v-value = p-character
    v-shift-num = (if num-entries(v-value, {&space-char}) > 2
                   then integer(entry(3, v-value, {&space-char}  ))
                   else 0)
    v-z-count =  (if num-entries(v-value, {&space-char}) > 3
                  then integer(entry(4, v-value, {&space-char} ))
                  else 0)
    v-chk-num = (if num-entries(v-value, {&space-char}) > 4
                 then integer(entry(5, v-value, {&space-char}))
                 else  0)
    .
    run cd-attr-parse-date-time-proc in this-procedure
      (input  substring(v-value, 1 , 19)
      ,output v-time
      ,output v-date
      ) no-error .

    run str/lastchkd.w (
                    input "Введите параметры последнего полученного чека по данной кассе"
                   ,input ?
                   ,input 1 /*одна дата и время с секундами*/
                   ,input ""
                   ,input-output v-date
                   ,input-output v-date2
                   ,input-output v-time
                   ,input-output v-time2
                   ,input-output v-shift-num
                   ,input-output v-shift-num2
                   ,input-output v-z-count
                   ,input-output v-z-count2
                   ,input-output v-chk-num
                   ,input-output v-chk-num2
                   ,output v-ok
                   ) no-error .

    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             {&space-char}  +  string(v-time, "HH:MM:SS":U) +
             {&space-char} + string(v-shift-num) +
             {&space-char} + string(v-z-count) +
             {&space-char} + string(v-chk-num)

             .
    if v-ok and
    p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.

end procedure. /* cd-attr-last-check-params */

procedure cd-attr-last-check-maria :
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-date as date no-undo .
define variable v-p-date as date no-undo .
define variable v-num-recs as decimal no-undo .
define variable v-p-num-recs as integer no-undo .
define variable v-z-count as integer no-undo .
define variable v-p-z-count as integer no-undo .
define variable v-ok as logical no-undo .


  do
  on error undo, return error
  :

    assign
    v-value = p-value
    v-date =  (if num-entries(entry(1, v-value, {&space-char}), '-') > 1
              then  date( integer(entry(2, entry(1, v-value, {&space-char}), '-':U))
                   ,integer(entry(3, entry(1, v-value, {&space-char}), '-':U))
                   ,integer(entry(1, entry(1, v-value, {&space-char}), '-':U))
                   )
                   else 01/01/1990)
    v-z-count =  (if num-entries(v-value, {&space-char}) > 1
                  then integer(entry(2, v-value, {&space-char} ))
                  else 0)
    v-num-recs =  (if num-entries(v-value, {&space-char}) > 2
                  then decimal(entry(3, v-value, {&space-char} ))
                  else 0)
    v-p-date =  (if num-entries(v-value, {&space-char}) > 3
                then  date( integer(entry(2, entry(4, v-value, {&space-char}), '-':U))
                            ,integer(entry(3, entry(4, v-value, {&space-char}), '-':U))
                            ,integer(entry(1, entry(4, v-value, {&space-char}), '-':U))
                            )
                else 01/01/1990)
    v-p-z-count =  (if num-entries(v-value, {&space-char}) > 4
                  then integer(entry(5, v-value, {&space-char} ))
                  else 0)
    v-p-num-recs =  (if num-entries(v-value, {&space-char}) > 5
                  then integer(entry(6, v-value, {&space-char} ))
                  else 0)

    .
    run ref/lastchkm.w (
                    input "Введите параметры последнего полученного чека по данной кассе"
                   ,input-output v-date
                   ,input-output v-z-count
                   ,input-output v-num-recs
                   ,input-output v-p-date
                   ,input-output v-p-z-count
                   ,input-output v-p-num-recs
                   ,output v-ok
                   ) no-error .

    assign
    v-value = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +  {&space-char} +
             string(v-z-count) + {&space-char} +
             string(v-num-recs) + {&space-char} +
             string(YEAR(v-p-date), "9999":U) + "-":U +
             string(Month(v-p-date), "99":U) + "-":U +
             string(DAY(v-p-date), "99":U) + {&space-char} +
             string(v-p-z-count) + {&space-char} +
             string(v-p-num-recs)
             .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* cd-attr-last-check-maria */


procedure cd-attr-periodic-tasks :

  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  define variable v-value as character no-undo .
  define variable v-ok as logical no-undo .
  define variable v-obj-list as character no-undo .
  define variable v-params as character no-undo .


  do
  on error undo, return error
  :

    assign
    v-value = p-value
    v-obj-list = entry(1, v-value , {&space-char} )
    v-params = if num-entries(v-value, {&space-char}) > 1 then entry(2, v-value , {&space-char} ) else '':U

    .
    run ref/mariatsk.w (
                         input-output v-obj-list
                        ,input-output v-params
                        ,output v-ok
                        ) no-error .
    v-value = v-obj-list + {&space-char} + v-params.

    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* cd-attr-perioidic tasks */


procedure cd-attr_get-attr-int-proc :

  define parameter buffer buf_cash-desk  for ub.cash-desk .
  define input  parameter p-upper-attr-code    as character no-undo .
  define input  parameter p-attr-code    as character no-undo .
  define output parameter p-mes          as character no-undo .
  define output parameter p-return-value as integer   no-undo .

  define variable par-type as character no-undo .
  define variable v-character as character no-undo .
  define variable v-date as date no-undo .
  define variable v-decimal as decimal no-undo .
  define variable v-integer as integer no-undo .
  define variable v-logical as integer no-undo .

  do
  on error undo, return error return-value
  :
    run cd-attr-value in this-procedure
      (input   buf_cash-desk.db-num
      ,input  buf_cash-desk.obj-code
      ,input  buf_cash-desk.pos-type
      ,input  buf_cash-desk.cash-num
      ,input  p-upper-attr-code
      ,input  p-attr-code
      ,output v-character
      ,output v-date
      ,output v-decimal
      ,output v-integer
      ,output v-logical
      ,output par-type
      ) no-error .
    if error-status :error
    then do:
      assign
        p-mes = substitute("Не удалось получить значение атрибута &7 для кассы &1 &2&3:&4&5 &6"
                          ,buf_cash-desk.cash-num
                          , {&shop}
                          ,buf_cash-desk.obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          , p-attr-code
                          )
        p-return-value = ?
      .
      return .
    end.
    assign
    p-return-value = v-integer
    .

  end.

end procedure. /* cd-attr_get-attr-int-proc */


procedure cd-attr_get-attr-log-proc :

  define parameter buffer buf_cash-desk  for ub.cash-desk .
  define input  parameter p-upper-attr-code    as character no-undo .
  define input  parameter p-attr-code    as character no-undo .
  define output parameter p-mes          as character no-undo .
  define output parameter p-return-value as logical   no-undo .

  define variable v-character as character no-undo .
  define variable v-date as date no-undo .
  define variable v-decimal as decimal no-undo .
  define variable v-integer as integer no-undo .
  define variable v-logical as logical no-undo .

  define variable par-type as character no-undo .

  do
  on error undo, return error return-value
  :
    run cd-attr-value IN THIS-PROCEDURE
      (input  buf_cash-desk.db-num
      ,input  buf_cash-desk.obj-code
      ,input  buf_cash-desk.pos-type
      ,input  buf_cash-desk.cash-num
      ,input  p-upper-attr-code
      ,input  p-attr-code
      ,output v-character
      ,output v-date
      ,output v-decimal
      ,output v-integer
      ,output v-logical
      ,output par-type
      ) no-error .
    if error-status :error
    then do:
      assign
        p-mes = substitute("Не удалось получить значение атрибута &7 для кассы &1 &2&3:&4&5 &6"
                          ,buf_cash-desk.cash-num
                          , {&shop}
                          ,buf_cash-desk.obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          , p-attr-code
                          )
        p-return-value = ?
      .
      return.
    end.

    assign
      p-return-value = v-logical
    .

  end.

end procedure. /* cd-attr_get-attr-log */



procedure cd-attr_check-marketer :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define input parameter p-upper-code  like ub.cash-desk-attr.upper-attr-code  no-undo .
define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
define input parameter p-character as character no-undo .
define input parameter p-date      as date      no-undo .
define input parameter p-decimal   as decimal   no-undo .
define input parameter p-integer   as integer   no-undo .
define input parameter p-logical   as logical   no-undo .
define input parameter p-mode  as character no-undo .
/*может быть {&add-def} {&update} {&deletion}*/
define output parameter p-correct     as logical no-undo .
define output parameter p-error-code  as character no-undo .

define variable v-int as integer no-undo .
  do
  on error undo, return error
  :

    if p-mode = {&deletion} then do:
      assign
      p-correct = yes.
      return.
    end.
    if p-pos-type <> {&cd-type-maria}
    then do:
      return.
    end.
    assign
    v-int = integer(p-character)
    no-error .
    if error-status:error then do:
      return substitute("&1 &2", error-status:get-message(1) , return-value ).
    end.
    assign
    p-correct = yes.
  end.

end procedure. /* cd-attr_check-max-gds */

procedure cd-attr-spr-tara-ref :

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-character as character no-undo .
define input-output parameter p-date      as date      no-undo .
define input-output parameter p-decimal   as decimal   no-undo .
define input-output parameter p-integer   as integer   no-undo .
define input-output parameter p-logical   as logical   no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-attr-code as character no-undo .
define variable v-upper-attr-code as character no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr .


  do
  on error undo, return error return-value
  :

   case p-pos-type:
     when  {&cd-type-ncr-gm} then do:
      assign
      v-upper-attr-code = {&cda-ncr-gm_general}
      v-attr-code = {&cda-ncr-gm_general_tara-ref}
      .
     end.
     when  {&cd-type-ncr-as-r} then do:
      assign
      v-upper-attr-code = {&cda-ncr-as-r_general}
      v-attr-code = {&cda-ncr-as-r_general_tara-ref}
      .
     end.
   end case.
   find first buf_cash-desk-attr no-lock where
             buf_cash-desk-attr.db-num = p-db-num
         and buf_cash-desk-attr.obj-code = p-obj-code
         and buf_cash-desk-attr.cash-num = p-cash-num
         and buf_cash-desk-attr.pos-type = p-pos-type
         and buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
         and buf_cash-desk-attr.attr-code = (v-attr-code + {&delim-par} + "0":U) no-error.
   if available buf_Cash-desk-attr then do:
      assign
      v-value = p-character
      .
   end.

    run ref/ncrtarac.w (
                     input parparentproc
                   , input p-db-num
                   , input {&shop}
                   , input p-obj-code
                   , input p-pos-type
                   , input p-cash-num
                   , input "b-add"
                   , input-output v-rid-list ) no-error.

   find first buf_cash-desk-attr no-lock where
             buf_cash-desk-attr.db-num = p-db-num
         and buf_cash-desk-attr.obj-code = p-obj-code
         and buf_cash-desk-attr.cash-num = p-cash-num
         and buf_cash-desk-attr.pos-type = p-pos-type
         and buf_cash-desk-attr.upper-attr-code = v-upper-attr-code
         and buf_cash-desk-attr.attr-code = v-attr-code  no-error.
   if available buf_Cash-desk-attr then
   assign
   v-value = buf_cash-desk-attr.attr-value-character.

   if p-character <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-character = v-value
      .
    end.
  end.

end procedure. /* cd-attr-spr-tara-ref */

procedure cd-attr-di-tara-ref :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input parameter p-ucode like ub.cash-desk-attr.upper-attr-code no-undo .
define input parameter p-attr-code like ub.cash-desk-attr.attr-code no-undo .
define input parameter p-character as character no-undo .
define input parameter p-date      as date      no-undo .
define input parameter p-decimal   as decimal   no-undo .
define input parameter p-integer   as integer   no-undo .
define input parameter p-logical   as logical   no-undo .
define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :

    run ref/ncrtarac.w (
                     INPUT parparentproc
                   , input p-db-num
                   , input {&shop}
                   , input p-obj-code
                   , input p-pos-type
                   , input p-cash-num
                   , input ""
                   , input-output v-rid-list ) no-error.

  end.

end procedure. /* cd-attr-spr-tara-ref */


/*секция pop-up меню при ручном редактировании */

procedure cd-attr-manual-edit :

do
  on error undo, return error
  :

  define input  parameter p-ucode          as character no-undo . /* код секции */
  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .


    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.

    case p-ucode :
      &scop section-code cda-MAGIA-XML_operative
      {&section-manual-edit-code}
      &scop section-code cda-IBM-XML_operative
      {&section-manual-edit-code}
      &scop section-code cda-IBM-XML_general
      {&section-manual-edit-code}
      &scop section-code cda-AUTOTANK_operative
      {&section-manual-edit-code}
      &scop section-code cda-MARIA_operative
      {&section-manual-edit-code}
      &scop section-code cda-MARIA_general
      {&section-manual-edit-code}
      &scop section-code cda-NCR-GM_general
      {&section-manual-edit-code}
      &scop section-code cda-NCR-AS-R_general
      {&section-manual-edit-code}
      &scop section-code cda-IBS-TH_main
      {&section-manual-edit-code}
      &scop section-code cda-IBS-TH_devices
      {&section-manual-edit-code}
      &scop section-code cda-IBS-TH_fisreg
      {&section-manual-edit-code}
      &scop section-code cda-IBS-TH_rec-print
      {&section-manual-edit-code}
      &scop section-code cda-IBS-TH_interface
      {&section-manual-edit-code}
      &scop section-code cda-IBS-TH-MOB_main
      {&section-manual-edit-code}
      &scop section-code cda-IBS-TH-MOB_rec-print
      {&section-manual-edit-code}

      /* сюда добавлять новые параметры атрибутов касс */
      otherwise do:
        /*возвратиться 0*/
        /*undo, return error substitute("неизвестный атрибут кассы &1", p-code ).*/
      end.
    end.
  end.
end procedure.


procedure cd-attr-batch-edit :

do
  on error undo, return error
  :

  define input  parameter p-ucode          as character no-undo . /* код секции */
  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.


    case p-ucode :

      /* сюда добавлять новые параметры атрибутов касс */
      otherwise do:
        /*возвратиться 0*/
      end.
    end.
  end.
end procedure.

procedure cd-attr-send-param :

do
  on error undo, return error
  :
  define input  parameter p-ucode         as character no-undo . /* код секции */
  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-send-param     as logical no-undo .

    if index(p-code, {&delim-par}) > 0 then do:
      p-ucode = entry(1, p-ucode, {&delim-par}).
      p-code = entry(1, p-code, {&delim-par}).
    end.


    case p-code :
      &scop attr-code cda-NCR-GM_general_message-by-lim-sum-check
      &scop section-code cda-NCR-GM_general
      {&section-send-param-code}
      &scop attr-code cda-NCR-AS-R_general_message-by-lim-sum-check
      &scop section-code cda-NCR-AS-R_general
      {&section-send-param-code}
      &scop attr-code cda-NCR-GM_general_tara-ref
      &scop section-code cda-NCR-GM_general
      {&section-send-param-code}
      &scop attr-code cda-NCR-AS-R_general_tara-ref
      &scop section-code cda-NCR-AS-R_general
      {&section-send-param-code}
      &scop attr-code cda-IBM-XML_general_use-kbo
      &scop section-code cda-IBM-XML_general
      {&section-send-param-code}
      &scop section-code cda-IBS-TH_main
      {&section-send-param-code}
      &scop section-code cda-IBS-TH_devices
      {&section-send-param-code}
      &scop section-code cda-IBS-TH_fisreg
      {&section-send-param-code}
      &scop section-code cda-IBS-TH_rec-print
      {&section-send-param-code}
      &scop section-code cda-IBS-TH_interface
      {&section-send-param-code}
      &scop section-code cda-IBS-TH-MOB_main
      {&section-send-param-code}
      &scop section-code cda-IBS-TH-MOB_rec-print
      {&section-send-param-code}

      /* сюда добавлять новые параметры атрибутов касс */
      otherwise do:
        /*
        возвращается нет
        undo, return error substitute("неизвестный атрибут кассы &1", p-code ).
        */
      end.
    end.
  end.
end procedure.

/* ################## */
/* атрибуты товаров на фирме */

&glob type-attr-no-envd-h {&type-log}
&glob format-attr-no-envd-h   "+/ "
&glob label-attr-no-envd-h    "Не попадает под действие ЕНВД"
&glob tooltip-attr-no-envd-h  "Не попадает под действие системы налогообложения ЕНВД, установленной на фирме"
&glob user-can-edit-attr-no-envd-h  true
&glob output-display-attr-no-envd-h  true
&glob other-attr-no-envd-h  ""
&glob news-attr-no-envd-h true
&glob copy-attr-no-envd-h  true
&scop manual-edit-attr-no-envd-h  1
&scop batch-edit-attr-no-envd-h  1

/* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
&glob type-attr-oss-props-h {&type-char}
&glob format-attr-oss-props-h   "X(256)"
&glob label-attr-oss-props-h   "Настройки платежа ОСС"
&glob tooltip-attr-oss-props-h  "Настройки платежа Оператора Сотовой Связи"
&glob user-can-edit-attr-oss-props-h  false
&glob output-display-attr-oss-props-h  false
&glob other-attr-oss-props-h  "spr=gds-host-oss-props/display=gds-host-oss-propsd"
&glob news-attr-oss-props-h true
&glob copy-attr-oss-props-h  true
&scop manual-edit-attr-oss-props-h  0
&scop batch-edit-attr-oss-props-h  0
*/

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdshattr-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    case p-code :
      &scop attr-code attr-no-envd-h
      {&attr-temp-full-code}
      
      /* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
      &scop attr-code attr-oss-props-h
      {&attr-temp-full-code}
      */

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code ).
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdshattr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-no-envd-h
      {&attr-temp-code}
      
      /* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
      &scop attr-code attr-oss-props-h
      {&attr-temp-code}
      */

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара на фирме &1",  p-code) .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdshattr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code as character no-undo .   /* код атрибута */
  define input  parameter p-obj-type as character no-undo .  /* obj-type  */
  define input  parameter p-obj-code as int no-undo .        /*  obj-code */
  define input  parameter p-gds-code as int no-undo .        /*  gds-code */
  define output parameter p-value as character no-undo .  /* значение атрибута */
  define output parameter p-type     as character no-undo .

  define buffer buf-gds-host-attr for ub.gds-host-attr.

  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define var attr-host-code as int no-undo .

 { gbl/hostcode.i p-obj-type p-obj-code attr-host-code no-error }.


    run gdshattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-gds-host-attr no-lock where
                buf-gds-host-attr.host-code = attr-host-code and
                buf-gds-host-attr.attr-code = p-code and
                buf-gds-host-attr.gds-code  = p-gds-code no-error .
   if avail buf-gds-host-attr then do:
    assign
    p-value = buf-gds-host-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = {&type-log} then "no":U else "".
   end.
end.
end procedure.


procedure gdshattr-h-value :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code as character no-undo .   /* код атрибута */
  define input  parameter p-host-code as integer no-undo . /*кодф ирмы*/
  define input  parameter p-gds-code as int no-undo .        /*  gds-code */
  define output parameter p-value as character no-undo .  /* значение атрибута */
  define output parameter p-type     as character no-undo .

  define buffer buf-gds-host-attr for ub.gds-host-attr.

  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define var attr-host-code as int no-undo .

     run gdshattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf-gds-host-attr no-lock where
                buf-gds-host-attr.host-code = p-host-code and
                buf-gds-host-attr.attr-code = p-code and
                buf-gds-host-attr.gds-code  = p-gds-code no-error .
   if avail buf-gds-host-attr then do:
    assign
    p-value = buf-gds-host-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = {&type-log} then "no":U else "".
   end.
end.
end procedure.


procedure gdshattr-write :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .

    define buffer buf_gds-host-attr for ub.gds-host-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .

   { gbl/hostcode.i p-obj-type p-obj-code attr-host-code no-error }.

    run gdshattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-host-attr exclusive-lock where
               buf_gds-host-attr.gds-code  = p-gds-code AND
               buf_gds-host-attr.host-code  = attr-host-code AND
               buf_gds-host-attr.attr-code = p-code no-error .
    if not available buf_gds-host-attr then do:
      create buf_gds-host-attr .
      assign
        buf_gds-host-attr.gds-code  = p-gds-code
        buf_gds-host-attr.host-code  = attr-host-code
        buf_gds-host-attr.attr-code = p-code
        buf_gds-host-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    assign
    buf_gds-host-attr.attr-value = p-value no-error
    .

  end.

end procedure.


procedure gdshattr-EXIST :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .

    define buffer buf_gds-host-attr for ub.gds-host-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .

   { gbl/hostcode.i p-obj-type p-obj-code attr-host-code no-error }.

    run gdshattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-host-attr NO-lock where
               buf_gds-host-attr.gds-code  = p-gds-code AND
               buf_gds-host-attr.host-code  = attr-host-code AND
               buf_gds-host-attr.attr-code = p-code no-error .
    if available buf_gds-host-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure gdshattr-DELETE :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define output parameter p-DELETED  AS LOGICAL no-undo .

    define buffer buf_gds-host-attr for ub.gds-host-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .

   { gbl/hostcode.i p-obj-type p-obj-code attr-host-code no-error }.

    run gdshattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-host-attr exclusive-lock where
               buf_gds-host-attr.gds-code  = p-gds-code AND
               buf_gds-host-attr.host-code  = attr-host-code AND
               buf_gds-host-attr.attr-code = p-code no-error .
    if not available buf_gds-host-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
       delete buf_gds-host-attr.
      p-DELETED = YES.
    END.
  end.

end procedure.

procedure gdshattr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code attr-no-envd-h
      {&attr-news-code}
      
      /* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
      &scop attr-code attr-oss-props-h
      {&attr-news-code}
      */

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure gdshattr-copy :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-copy           as logical   no-undo . /* копируется при копировании товара - если включены соответ настройки */

    case p-code :
      &scop attr-code attr-no-envd-h
      {&attr-copy-code}
      
      /* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
      &scop attr-code attr-oss-props-h
      {&attr-copy-code}
      */

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure gdshattr-manual-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-no-envd-h
      {&attr-manual-edit-code }
      
      /* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
      &scop attr-code attr-oss-props-h
      {&attr-manual-edit-code}
      */


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.


procedure gdshattr-batch-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-no-envd-h
      {&attr-batch-edit-code }
      
      /* 26/II-2019 не используется. Справочник операторов сотовой связи (ОСС) перенесён в БПА
      &scop attr-code attr-oss-props-h
      {&attr-batch-edit-code}
      */


            /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на фирме &1", p-code) .
      end.
    end.
  end.
end procedure.






/* ################## */
/* атрибуты товаров на объекте */

/* Атрибут для блокирования остальных атрибутов в интерфейсе */
&scop type-attr-gds-obj-attr-lock-o {&type-log}
&scop format-attr-gds-obj-attr-lock-o  "yes/no"
&scop label-attr-gds-obj-attr-lock-o   "Блокировка атрибутов на изменение"
&scop tooltip-attr-gds-obj-attr-lock-o   "Блокировка атрибутов на изменение"
&scop user-can-edit-attr-gds-obj-attr-lock-o  false
&scop output-display-attr-gds-obj-attr-lock-o  false
&scop other-attr-gds-obj-attr-lock-o  ""
&scop copy-attr-gds-obj-attr-lock-o  false
&scop manual-edit-attr-gds-obj-attr-lock-o 0
&scop batch-edit-attr-gds-obj-attr-lock-o  0

/* Весовой код на объекте */
&scop type-attr-scales-code-o {&type-int}
&scop format-attr-scales-code-o  "99999"
&scop label-attr-scales-code-o   "Код для весов на объекте"
&scop tooltip-attr-scales-code-o   "Код для весов, который будет отослан на весы для данного товара на данном объекте"
&scop user-can-edit-attr-scales-code-o  false
&scop output-display-attr-scales-code-o  true
&scop other-attr-scales-code-o  ""
&scop copy-attr-scales-code-o  false
&scop manual-edit-attr-scales-code-o  0
&scop batch-edit-attr-scales-code-o  0


/* Товар со свободной ценой на кассе */
&scop type-attr-free-price-o {&type-log}
&scop format-attr-free-price-o  "+/ "
&scop label-attr-free-price-o   "Товар со свободной ценой на кассе"
&scop tooltip-attr-free-price-o   "Кассир вручную вводит цену товара на кассе (IBM-POS, IBS TH POS)"
&scop user-can-edit-attr-free-price-o  true
&scop output-display-attr-free-price-o  true
&scop other-attr-free-price-o  "cd=gds"
&scop copy-attr-free-price-o  false
&scop manual-edit-attr-free-price-o  2
&scop batch-edit-attr-free-price-o  2

/* Группа товаров на кассе */
&scop type-attr-sum-grp-o {&type-int}
&scop format-attr-sum-grp-o  "999"
&scop label-attr-sum-grp-o   "Группа товаров на кассе"
&scop tooltip-attr-sum-grp-o   "Номер группы товаров на кассе (IBM-POS, IBS TH POS)"
&scop user-can-edit-attr-sum-grp-o  true
&scop output-display-attr-sum-grp-o  true
&scop other-attr-sum-grp-o  "spr=gds-obj-sum-grps/cd=gds"
&scop copy-attr-sum-grp-o  true
&scop manual-edit-attr-sum-grp-o  2
&scop batch-edit-attr-sum-grp-o  2

/* Наценка на объекте */
&scop type-attr-increase-pc-o {&type-dec}
&scop format-attr-increase-pc-o  "99999.99"
&scop label-attr-increase-pc-o   "Наценка"
&scop tooltip-attr-increase-pc-o   "Наценка на объекте"
&scop user-can-edit-attr-increase-pc-o  true
&scop output-display-attr-increase-pc-o  true
&scop other-attr-increase-pc-o  "init=gds-obj-init-increase-pc"
&scop copy-attr-increase-pc-o  true
&scop manual-edit-attr-increase-pc-o  1
&scop batch-edit-attr-increase-pc-o  1

/* Минимальный запас */
&scop type-attr-min-zapas-o {&type-dec}
&scop format-attr-min-zapas-o  ">>>>>>>>>9"
&scop label-attr-min-zapas-o   "Минимальный запас"
&scop tooltip-attr-min-zapas-o   "Минимальный запас на объекте"
&scop user-can-edit-attr-min-zapas-o  true
&scop output-display-attr-min-zapas-o  true
&scop other-attr-min-zapas-o  '':u
&scop copy-attr-min-zapas-o  true
&scop manual-edit-attr-min-zapas-o  1
&scop batch-edit-attr-min-zapas-o  1

/* Метод округления цены при расчете переоценки */
&scop type-attr-round-method-o {&type-char}
&scop format-attr-round-method-o  "X(21)"
&scop label-attr-round-method-o   "Метод округления "
&scop tooltip-attr-round-method-o   "Метод округления цены при расчете переоценки"
&scop user-can-edit-attr-round-method-o  true
&scop output-display-attr-round-method-o  true
&scop other-attr-round-method-o "spr=gds-obj-round-method"
&scop copy-attr-round-method-o  true
&scop manual-edit-attr-round-method-o  1
&scop batch-edit-attr-round-method-o  1

/* Товар оплачивается топливным кошельком смарт карты (IBM-POS) */
&scop type-attr-petrol-purse-o {&type-log}
&scop format-attr-petrol-purse-o  "+/-"
&scop label-attr-petrol-purse-o   "Топливный кошелек (IBM-POS)"
&scop tooltip-attr-petrol-purse-o   "Товар оплачивается топливным кошельком смарт карты (IBM-POS)"
&scop user-can-edit-attr-petrol-purse-o  true
&scop output-display-attr-petrol-purse-o  true
&scop other-attr-petrol-purse-o "cd=gds"
&scop copy-attr-petrol-purse-o  false
&scop manual-edit-attr-petrol-purse-o  2
&scop batch-edit-attr-petrol-purse-o  2

/* Товар оплачивается топливным кошельком смарт карты (IBM-POS) */
&scop type-attr-need-auth-o {&type-log}
&scop format-attr-need-auth-o  "+/-"
&scop label-attr-need-auth-o   "Требует авторизации на кассе (IBM-XML)"
&scop tooltip-attr-need-auth-o   "Товар требует авторизации на кассе (IBM-XML)"
&scop user-can-edit-attr-need-auth-o  true
&scop output-display-attr-need-auth-o  true
&scop other-attr-need-auth-o "cd=gds"
&scop copy-attr-need-auth-o  false
&scop manual-edit-attr-need-auth-o  2
&scop batch-edit-attr-need-auth-o  2

/* Диапазоны торговой наценки при расчете переоценки */
&scop type-attr-gds-margins-o {&type-char}
&scop format-attr-gds-margins-o  "X(21)"
&scop label-attr-gds-margins-o   "Диапазоны торговой наценки"
&scop tooltip-attr-gds-margins-o   "Диапазоны торговой наценки при расчете переоценки"
&scop user-can-edit-attr-gds-margins-o  true
&scop output-display-attr-gds-margins-o  true
&scop other-attr-gds-margins-o "spr=gds-obj-gds-margins"
&scop copy-attr-gds-margins-o  true
&scop manual-edit-attr-gds-margins-o  1
&scop batch-edit-attr-gds-margins-o  1

/* Принадлежность товара объекту в пределах одной ТПСИ */
&scop type-attr-proprietor-o {&type-log}
&scop format-attr-proprietor-o  "+/-"
&scop label-attr-proprietor-o   "Принадлежность товара объекту"
&scop tooltip-attr-proprietor-o   "Принадлежность товара объекту в пределах одной ТПСИ"
&scop user-can-edit-attr-proprietor-o  true
&scop output-display-attr-proprietor-o  true
&scop other-attr-proprietor-o "check-ext=ref\gopropri.p"
&scop copy-attr-proprietor-o  false
&scop manual-edit-attr-proprietor-o  1
&scop batch-edit-attr-proprietor-o  1

/* Оценочная учетная цена ингредиента для калькуляционной карточки */
&scop type-attr-fbr-cost-rubl {&type-dec}
&scop format-attr-fbr-cost-rubl  ">>>>>>>>>9.999"
&scop label-attr-fbr-cost-rubl   "Оценочная учетная цена ингредиента"
&scop tooltip-attr-fbr-cost-rubl   "Оценочная учетная цена ингредиента для калькуляционной карточки"
&scop user-can-edit-attr-fbr-cost-rubl  true
&scop output-display-attr-fbr-cost-rubl  true
&scop other-attr-fbr-cost-rubl  "":U
&scop copy-attr-fbr-cost-rubl  true
&scop manual-edit-attr-fbr-cost-rubl  4
&scop batch-edit-attr-fbr-cost-rubl  4

/* Запрещен внешний приход и заказ объект-поставщик по товару на объекте */
&scop type-attr-no-income-goods {&type-log}
&scop format-attr-no-income-goods  "+/ "
&scop label-attr-no-income-goods   "Запрещен внешний приход и заказ объект-поставщик по товару на объекте"
&scop tooltip-attr-no-income-goods "Запрещен внешний приход и заказ объект-поставщик по товару на объекте"
&scop user-can-edit-attr-no-income-goods  false
&scop output-display-attr-no-income-goods  false
&scop other-attr-no-income-goods  "":U
&scop copy-attr-no-income-goods  true
&scop manual-edit-attr-no-income-goods  5
&scop batch-edit-attr-no-income-goods  5

/* Код тары для сканер-весов NCR */
&scop type-attr-taracode-o {&type-int}
&scop format-attr-taracode-o  "99"
&scop label-attr-taracode-o   "Код тары для сканер-весов NCR"
&scop tooltip-attr-taracode-o "Код тары для сканер-весов NCR"
&scop user-can-edit-attr-taracode-o  true
&scop output-display-attr-taracode-o  true
&scop other-attr-taracode-o  "spr=gds-obj-taracode":U
&scop copy-attr-taracode-o  true
&scop manual-edit-attr-taracode-o  2
&scop batch-edit-attr-taracode-o  2

&glob type-attr-calories-o {&type-dec}
&glob format-attr-calories-o  ">,>>9.9"
&glob label-attr-calories-o   "Энерг.ценность ккал на 100г"
&glob tooltip-attr-calories-o   "Энерг.ценность ккал на 100г"
&glob user-can-edit-attr-calories-o  true
&glob output-display-attr-calories-o  true
&glob other-attr-calories-o  ""
&glob news-attr-calories-o true
&glob copy-attr-calories-o  false
&scop manual-edit-attr-calories-o 0
&scop batch-edit-attr-calories-o  0

&glob type-attr-protein-o {&type-dec}
&glob format-attr-protein-o  ">9.9"
&glob label-attr-protein-o   "Белки г на 100г"
&glob tooltip-attr-protein-o   "Белки г на 100г"
&glob user-can-edit-attr-protein-o  true
&glob output-display-attr-protein-o  true
&glob other-attr-protein-o  ""
&glob news-attr-protein-o true
&glob copy-attr-protein-o  false
&scop manual-edit-attr-protein-o 0
&scop batch-edit-attr-protein-o  0

&glob type-attr-fat-o {&type-dec}
&glob format-attr-fat-o  ">9.9"
&glob label-attr-fat-o   "Жиры г на 100г"
&glob tooltip-attr-fat-o   "Жиры г на 100г"
&glob user-can-edit-attr-fat-o  true
&glob output-display-attr-fat-o  true
&glob other-attr-fat-o  ""
&glob news-attr-fat-o true
&glob copy-attr-fat-o  false
&scop manual-edit-attr-fat-o 0
&scop batch-edit-attr-fat-o  0

&glob type-attr-carbohydrate-o {&type-dec}
&glob format-attr-carbohydrate-o  ">9.9"
&glob label-attr-carbohydrate-o   "Углеводы г на 100г"
&glob tooltip-attr-carbohydrate-o   "Углеводы г на 100г"
&glob user-can-edit-attr-carbohydrate-o  true
&glob output-display-attr-carbohydrate-o  true
&glob other-attr-carbohydrate-o  ""
&glob news-attr-carbohydrate-o true
&glob copy-attr-carbohydrate-o  false
&scop manual-edit-attr-carbohydrate-o 0
&scop batch-edit-attr-carbohydrate-o  0


/* Способ задания количества ценников при печати из документа */
&scop type-attr-doc-tickets-o {&type-char}
&scop format-attr-doc-tickets-o  "X(21)"
&scop label-attr-doc-tickets-o   "Количество ценников"
&scop tooltip-attr-doc-tickets-o   "Способ задания количества ценников при печати из документа"
&scop user-can-edit-attr-doc-tickets-o  true
&scop output-display-attr-doc-tickets-o  true
&scop other-attr-doc-tickets-o "spr=gds-obj-doc-tickets"
&scop copy-attr-doc-tickets-o  true
&scop manual-edit-attr-doc-tickets-o  1
&scop batch-edit-attr-doc-tickets-o  1

&glob type-attr-normal-wastage-o {&type-char}
&glob format-attr-normal-wastage-o  "X(21)"
&glob label-attr-normal-wastage-o   "Нормы естественной убыли для топлива кг/т"
&glob tooltip-attr-normal-wastage-o   "Нормы естественной убыли для топлива кг/т"
&glob user-can-edit-attr-normal-wastage-o  true
&glob output-display-attr-normal-wastage-o  true
&glob other-attr-normal-wastage-o  "spr=gds-obj-normal-wastage"
&glob news-attr-normal-wastage-o true
&glob copy-attr-normal-wastage-o  true
&scop manual-edit-attr-normal-wastage-o 1
&scop batch-edit-attr-normal-wastage-o  1


/* Дополнение к альтернативному названию */
&scop type-attr-dop-alt-name-o {&type-char}
&scop format-attr-dop-alt-name-o  "X(40)"
&scop label-attr-dop-alt-name-o   "Дополнение к названию товара"
&scop tooltip-attr-dop-alt-name-o   "Дополнение к названию товара"
&scop user-can-edit-attr-dop-alt-name-o  true
&scop output-display-attr-dop-alt-name-o  true
&scop other-attr-dop-alt-name-o "spr=gds-obj-dop-alt-name"
&scop copy-attr-dop-alt-name-o  true
&scop manual-edit-attr-dop-alt-name-o  1
&scop batch-edit-attr-dop-alt-name-o  1

/* дата/время изменения сезона */

&glob type-attr-change-dt-seasons {&type-char}
&glob format-attr-change-dt-seasons  "X(50)"
&glob label-attr-change-dt-seasons   "дата/время изменения сезон"
&glob tooltip-attr-change-dt-seasons   "дата/время изменения сезон"
&glob user-can-edit-attr-change-dt-seasons  false
&glob output-display-attr-change-dt-seasons  false
&glob other-attr-change-dt-seasons  ""
&glob news-attr-change-dt-seasons true
&glob copy-attr-change-dt-seasons  false
&scop manual-edit-attr-change-dt-seasons 2
&scop batch-edit-attr-change-dt-seasons  2

/* Сезон топлива */

&glob type-attr-dt-seasons {&type-char}
&glob format-attr-dt-seasons  "X(50)"
&glob label-attr-dt-seasons   "Сезон ДТ"
&glob tooltip-attr-dt-seasons   "Сезон ДТ"
&glob user-can-edit-attr-dt-seasons  true
&glob output-display-attr-dt-seasons  true
&glob other-attr-dt-seasons  "spr=gds-obj-dt-seasons/cd=IBM-XML/send2kassa=promoAction"
&glob news-attr-dt-seasons true
&glob copy-attr-dt-seasons  true
&scop manual-edit-attr-dt-seasons 2
&scop batch-edit-attr-dt-seasons  2

/* Тип сбора марок */
&scop type-attr-mark-collect-type {&type-int}
&scop format-attr-mark-collect-type  "9"
&scop label-attr-mark-collect-type   "Тип сбора марок"
&scop tooltip-attr-mark-collect-type   "Тип сбора марок"
&scop user-can-edit-attr-mark-collect-type  false
&scop output-display-attr-mark-collect-type  true
&scop other-attr-mark-collect-type  ""
&glob news-attr-mark-collect-type true
&scop copy-attr-mark-collect-type false
&scop manual-edit-attr-mark-collect-type  0
&scop batch-edit-attr-mark-collect-type  0

/* сюда добавлять новые параметры атрибутов товаров на объекте */


&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-copy-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-copy = ~{&copy-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdsoattr-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    case p-code :
      &scop attr-code attr-gds-obj-attr-lock-o
      {&attr-temp-full-code}
      &scop attr-code attr-scales-code-o
      {&attr-temp-full-code}
      &scop attr-code attr-free-price-o
      {&attr-temp-full-code}
      &scop attr-code attr-sum-grp-o
      {&attr-temp-full-code}
      &scop attr-code attr-increase-pc-o
      {&attr-temp-full-code}
      &scop attr-code attr-min-zapas-o
      {&attr-temp-full-code}
      &scop attr-code attr-round-method-o
      {&attr-temp-full-code}
      &scop attr-code attr-petrol-purse-o
      {&attr-temp-full-code}
      &scop attr-code attr-need-auth-o
      {&attr-temp-full-code}
      &scop attr-code attr-gds-margins-o
      {&attr-temp-full-code}
      &scop attr-code attr-proprietor-o
      {&attr-temp-full-code}
      &scop attr-code attr-fbr-cost-rubl
      {&attr-temp-full-code}
      &scop attr-code attr-no-income-goods
      {&attr-temp-full-code}
      &scop attr-code attr-taracode-o
      {&attr-temp-full-code}
      &scop attr-code attr-calories-o
      {&attr-temp-full-code}
      &scop attr-code attr-protein-o
      {&attr-temp-full-code}
      &scop attr-code attr-fat-o
      {&attr-temp-full-code}
      &scop attr-code attr-carbohydrate-o
      {&attr-temp-full-code}
      &scop attr-code attr-doc-tickets-o
      {&attr-temp-full-code}
      &scop attr-code attr-normal-wastage-o
      {&attr-temp-full-code}
      &scop attr-code attr-dop-alt-name-o
      {&attr-temp-full-code}
      &scop attr-code attr-dt-seasons
      {&attr-temp-full-code}
      &scop attr-code attr-change-dt-seasons
      {&attr-temp-full-code}
      &scop attr-code attr-mark-collect-type
      {&attr-temp-full-code}
       /* сюда добавлять новые параметры атрибутов товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdsoattr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-scales-code-o
      {&attr-temp-code}
      &scop attr-code attr-free-price-o
      {&attr-temp-code}
      &scop attr-code attr-sum-grp-o
      {&attr-temp-code}
      &scop attr-code attr-increase-pc-o
      {&attr-temp-code}
      &scop attr-code attr-min-zapas-o
      {&attr-temp-code}
      &scop attr-code attr-round-method-o
      {&attr-temp-code}
      &scop attr-code attr-petrol-purse-o
      {&attr-temp-code}
      &scop attr-code attr-need-auth-o
      {&attr-temp-code}
      &scop attr-code attr-gds-margins-o
      {&attr-temp-code}
      &scop attr-code attr-proprietor-o
      {&attr-temp-code}
      &scop attr-code attr-fbr-cost-rubl
      {&attr-temp-code}
      &scop attr-code attr-no-income-goods
      {&attr-temp-code}
      &scop attr-code attr-taracode-o
      {&attr-temp-code}
      &scop attr-code attr-calories-o
      {&attr-temp-code}
      &scop attr-code attr-protein-o
      {&attr-temp-code}
      &scop attr-code attr-fat-o
      {&attr-temp-code}
      &scop attr-code attr-carbohydrate-o
      {&attr-temp-code}
      &scop attr-code attr-doc-tickets-o
      {&attr-temp-code}
      &scop attr-code attr-normal-wastage-o
      {&attr-temp-code}
      &scop attr-code attr-dop-alt-name-o
      {&attr-temp-code}
      &scop attr-code attr-dt-seasons
      {&attr-temp-code}
      &scop attr-code attr-change-dt-seasons
      {&attr-temp-code}
      &scop attr-code attr-mark-collect-type
      {&attr-temp-code}

      /* сюда добавлять новые параметры атрибутов товаров на объекте */
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdsoattr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdsoattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-obj-attr no-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code
      no-error .
    if avail buf_gds-obj-attr then do:
      assign
        p-value =  buf_gds-obj-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
/* alek поиск кода товара по значению привязанного атрибута к товару для объекта*/
procedure gdsoattr-gds-code :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .

    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    find first buf_gds-obj-attr no-lock where
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code  = p-code AND
               buf_gds-obj-attr.attr-value = p-value
      no-error .
    if avail buf_gds-obj-attr then
      p-gds-code =  buf_gds-obj-attr.gds-code.
  end.

end procedure.

procedure gdsoattr-write :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .

    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define buffer lock_gds-obj-attr for ub.gds-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdsoattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    /*
    воможный вариант локировки с помощью дополнительного атрибута
    find first lock_gds-obj-attr exclusive-lock where
               lock_gds-obj-attr.gds-code  = p-gds-code AND
               lock_gds-obj-attr.obj-type  = p-obj-type AND
              lock_gds-obj-attr.obj-code  = p-obj-code AND
              lock_gds-obj-attr.attr-code = {&attr-lock} no-error no-wait .
    if locked lock_gds-obj-attr then do:
      undo, return error {&attr-lock}.
    end.
    if not available lock_gds-obj-attr
    and not locked lock_gds-obj-attr
    then do:
      create lock_gds-obj-attr.
      assign
      lock_gds-obj-attr.gds-code  = p-gds-code
      lock_gds-obj-attr.obj-type  = p-obj-type
      lock_gds-obj-attr.obj-code  = p-obj-code
      lock_gds-obj-attr.attr-code = {&attr-lock}
      no-error
      .
    end.
    find current lock_gds-obj-attr share-lock.
    */
    find first buf_gds-obj-attr exclusive-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-attr then do:
      create buf_gds-obj-attr .
      assign
        buf_gds-obj-attr.gds-code  = p-gds-code
        buf_gds-obj-attr.obj-type  = p-obj-type
        buf_gds-obj-attr.obj-code  = p-obj-code
        buf_gds-obj-attr.attr-code = p-code
        buf_gds-obj-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_gds-obj-attr.attr-value = p-value no-error.
  end.

end procedure.


procedure gdsoattr-exist :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_gds-obj-attr for ub.gds-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdsoattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-obj-attr no-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code no-error .
    if available buf_gds-obj-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure gdsoattr-delete :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_gds-obj-attr for ub.gds-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdsoattr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-obj-attr exclusive-lock where
               buf_gds-obj-attr.gds-code  = p-gds-code AND
               buf_gds-obj-attr.obj-type  = p-obj-type AND
               buf_gds-obj-attr.obj-code  = p-obj-code AND
               buf_gds-obj-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_gds-obj-attr.
       P-DELETED = YES.
    END.
  end.

end procedure.

procedure gds-obj-gds-margins :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/gdsprmar.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* gds-obj-gds-margin */

procedure gds-obj-normal-wastage :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/gdswastage.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .
                   
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* gds-obj-normal-wastage */

procedure gds-obj-doc-tickets :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/dctiattr.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* gds-obj-doc-tickets */

procedure gds-obj-dop-alt-name :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/dopaltn.w (
                    input p-gds-code
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input-output v-value) no-error .

    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* gds-obj-dop-alt-name */


procedure gds-attr-margin-value :
do
on error undo, return error
:
define input parameter p-gds-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-rmethod as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase  as logical no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod   as logical no-undo .
define variable v-nume as integer no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-rmethod as character no-undo .
define variable v-base as decimal no-undo .
define variable v-exists-margin as logical no-undo .
define variable v-exists-increase as logical no-undo .
define variable v-exists-rmethod as logical no-undo .
define variable v-mes as character no-undo .

define buffer buf_goods for ub.goods.
define buffer buf_margins-gds-obj-attr      for ub.gds-obj-attr.
define buffer buf_increase-gds-obj-attr      for ub.gds-obj-attr.
define buffer buf_round-gds-obj-attr      for ub.gds-obj-attr.

find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .
if not avail buf_goods then do:
  message
    skip "Не удалось найти товар с кодом" p-gds-code
    view-as alert-box error .
  undo, return error .
end.

find first buf_margins-gds-obj-attr no-lock
    where buf_margins-gds-obj-attr.gds-code = p-gds-code
      and buf_margins-gds-obj-attr.attr-code = {&attr-gds-margins-o}
      and buf_margins-gds-obj-attr.obj-type  = p-obj-type
      and buf_margins-gds-obj-attr.obj-code  = p-obj-code
no-error .
if available buf_margins-gds-obj-attr then do:
  assign
  v-min-value   =  decimal(trim(entry(1, buf_margins-gds-obj-attr.attr-value, "-":U), "%":U))
  v-max-value   =  decimal(trim(entry(2, buf_margins-gds-obj-attr.attr-value, "-":U), "%":U))
  v-exists-margin = v-min-value <> ? and v-max-value <> ?
  .
end.
find first buf_increase-gds-obj-attr no-lock
    where buf_increase-gds-obj-attr.gds-code = p-gds-code
      and buf_increase-gds-obj-attr.attr-code = {&attr-increase-pc-o}
      and buf_increase-gds-obj-attr.obj-type  = p-obj-type
      and buf_increase-gds-obj-attr.obj-code  = p-obj-code
no-error .
if available buf_increase-gds-obj-attr then do:
  assign
  v-increase-pc = decimal(buf_increase-gds-obj-attr.attr-value)
  v-exists-increase = yes

  .
end.

find first buf_round-gds-obj-attr no-lock
    where buf_round-gds-obj-attr.gds-code = p-gds-code
      and buf_round-gds-obj-attr.attr-code = {&attr-round-method-o}
      and buf_round-gds-obj-attr.obj-type  = p-obj-type
      and buf_round-gds-obj-attr.obj-code  = p-obj-code
no-error .
if available buf_round-gds-obj-attr then do:
  assign
  v-rmethod =  entry(1, buf_round-gds-obj-attr.attr-value, {&space-char})
  v-nume    = num-entries(buf_round-gds-obj-attr.attr-value, {&space-char})
  v-base     = (if v-nume >= 2 and entry(v-nume, buf_round-gds-obj-attr.attr-value, {&space-char}) <> "":U
                then decimal (entry(v-nume, buf_round-gds-obj-attr.attr-value, {&space-char}))
                else 0
                    )
  v-exists-rmethod = yes
  no-error.
  if error-status :error   or (LOOKUP(p-rmethod, {&pr-rounds}) = 0 and p-rmethod <> "":U)
  then do:
    assign
    v-mes = "Ошибка при чтении метода округления" + {&new-line} +
           return-value + {&new-line} +
           trim(error-status :get-message(1)) + {&new-line} +
           trim(error-status :get-message(2)) + {&new-line} +
           trim(error-status :get-message(3)) + {&new-line} +
           trim(error-status :get-message(4)) + {&new-line} +
           trim(error-status :get-message(5)).
    return error v-mes.
  end.
end.
if not (v-exists-margin and v-exists-increase and v-exists-rmethod) then do:
  run grp-obj-margin-value  in this-procedure (
 input  buf_goods.grp-code
,input  p-obj-type
,input  p-obj-code
,output p-min-value
,output p-max-value
,output p-increase-pc
,output p-rmethod
,output p-base
,output p-range-margin
,output p-exists-margin
,output p-range-increase
,output p-exists-increase
,output p-range-rmethod
,output p-exists-rmethod ) no-error .
if error-status:error then do:
    assign
    v-mes = substitute("Ошибка при чтении параметров переоценки из группы для товара &1", p-gds-code) + {&new-line} +
           return-value + {&new-line} +
           trim(error-status :get-message(1)) + {&new-line} +
           trim(error-status :get-message(2)) + {&new-line} +
           trim(error-status :get-message(3)) + {&new-line} +
           trim(error-status :get-message(4)) + {&new-line} +
           trim(error-status :get-message(5)).
      return error v-mes.
end.
end.
assign
p-min-value = (if v-exists-margin then v-min-value else p-min-value)
p-max-value = (if v-exists-margin then v-max-value else p-max-value)
p-exists-margin = (if v-exists-margin then v-exists-margin else p-exists-margin)
p-increase-pc = (if v-exists-increase then v-increase-pc else p-increase-pc)
p-rmethod = (if v-exists-rmethod then v-rmethod else p-rmethod)
p-base    = (if v-exists-rmethod then v-base else p-base)
p-range-margin  = (if v-exists-margin then (- 1) else p-range-margin)
p-range-increase = (if v-exists-increase then (- 1) else p-range-increase)
p-range-rmethod  = (if v-exists-rmethod then  (- 1 )else p-range-rmethod)
.
end. /*doe*/
end procedure.


procedure gds-o-normal-wastage-value :
do
on error undo, return error
:
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.

  define variable v-mes as character no-undo .
  define variable v-value as character no-undo.
  define variable v-type as character no-undo.
  
  if not valid-object (objNormWast)
  then do:
     message
      skip "objNormWast is null reference"
      view-as alert-box error .
    undo, return error .
  end.
  
  if not valid-object (objNormWast:ParGdsOAttr)
  then do:
     message
      skip "objNormWast:ParGdsOAttrObj is null reference"
      view-as alert-box error .
    undo, return error .
  end.
  
  define buffer buf_goods for ub.goods.
  define buffer buf_normal-wastage-gds-obj-attr      for ub.gds-obj-attr.
  
  find first buf_goods no-lock where
             buf_goods.gds-code = objNormWast:ParGdsOAttr:GdsCode no-error .
  if not avail buf_goods then do:
    message
      skip "Не удалось найти товар с кодом" objNormWast:ParGdsOAttr:GdsCode
      view-as alert-box error .
    undo, return error .
  end.

  find first buf_normal-wastage-gds-obj-attr no-lock
      where buf_normal-wastage-gds-obj-attr.gds-code = objNormWast:ParGdsOAttr:GdsCode
        and buf_normal-wastage-gds-obj-attr.attr-code = {&attr-normal-wastage-o}
        and buf_normal-wastage-gds-obj-attr.obj-type  = objNormWast:ParGdsOAttr:ObjType
        and buf_normal-wastage-gds-obj-attr.obj-code  = objNormWast:ParGdsOAttr:ObjCode
  no-error .
  if available buf_normal-wastage-gds-obj-attr then do:

    define variable v-temp-str1 as character no-undo .
    v-temp-str1 = buf_normal-wastage-gds-obj-attr.attr-value.
    
    case num-entries (v-temp-str1, ";"):
      when 2 then do:
        assign
          objNormWast:NormalWastageSummer =  decimal(trim(entry(1, v-temp-str1, ";":U)))
          objNormWast:NormalWastageWinter =  decimal(trim(entry(2, v-temp-str1, ";":U)))
        .        
      end.
      when 4 then do:
        assign
          objNormWast:NormalWastageTransSummer   =  decimal(trim(entry(1, v-temp-str1, ";":U)))
          objNormWast:NormalWastageTransWinter   =  decimal(trim(entry(2, v-temp-str1, ";":U)))
          objNormWast:NormalWastageSummer   =  decimal(trim(entry(3, v-temp-str1, ";":U)))
          objNormWast:NormalWastageWinter   =  decimal(trim(entry(4, v-temp-str1, ";":U)))
        .        
      end.
      when 0 then do:
        assign
          objNormWast:NormalWastageSummer   =  decimal(trim(v-temp-str1))
          objNormWast:NormalWastageWinter   =  decimal(trim(v-temp-str1))
        .       
      end.
    end case.

    find first buf_normal-wastage-gds-obj-attr no-lock
        where buf_normal-wastage-gds-obj-attr.gds-code = objNormWast:ParGdsOAttr:GdsCode
          and buf_normal-wastage-gds-obj-attr.attr-code = {&attr-cli-decommissioned}
          and buf_normal-wastage-gds-obj-attr.obj-type  = objNormWast:ParGdsOAttr:ObjType
          and buf_normal-wastage-gds-obj-attr.obj-code  = objNormWast:ParGdsOAttr:ObjCode
    no-error .
    
    run clntattr-value in this-procedure (input objNormWast:ParGdsOAttr:ObjType,
                                          input objNormWast:ParGdsOAttr:ObjCode,
                                          input {&attr-cli-decommissioned},
                                          output v-value,
                                          output v-type) no-error.
    objNormWast:IsDecommissioned = (v-value = "yes":u).

    run clntattr-value in this-procedure (input objNormWast:ParGdsOAttr:ObjType,
                                          input objNormWast:ParGdsOAttr:ObjCode,
                                          input {&attr-cli-clim-grp},
                                          output v-value,
                                          output v-type) no-error.
    
    if num-entries(v-value) = 3 then assign
      objNormWast:BeginSummer = date (entry(2, v-value))
      objNormWast:BeginWinter  = date (entry(3, v-value))
    .
    else do:
      objNormWast:BeginSummer = 01/03.
      objNormWast:BeginWinter = 01/10.
    end.
    
    if objNormWast:ParGdsOAttr:OnDate <> ?
    then do:
      if objNormWast:BeginSummer <= objNormWast:ParGdsOAttr:OnDate and objNormWast:ParGdsOAttr:onDate < objNormWast:BeginWinter
      then do:
        objNormWast:NormalWastageDate = objNormWast:NormalWastageSummer.
        objNormWast:NormalWastageTransDate = objNormWast:NormalWastageTransSummer.
      end.
      else do:
        objNormWast:NormalWastageDate = objNormWast:NormalWastageWinter.
        objNormWast:NormalWastageTransDate = objNormWast:NormalWastageTransWinter.
      end.
       
    end.
    
  end.

end. /*doe*/
end procedure.


procedure gdsoattr-copy :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-copy           as logical   no-undo . /* копируется при копировании товара - если включены соответ настройки */

    case p-code :
      &scop attr-code attr-scales-code-o
      {&attr-copy-code}
      &scop attr-code attr-free-price-o
      {&attr-copy-code}
      &scop attr-code attr-sum-grp-o
      {&attr-copy-code}
      &scop attr-code attr-increase-pc-o
      {&attr-copy-code}
      &scop attr-code attr-min-zapas-o
      {&attr-copy-code}
      &scop attr-code attr-round-method-o
      {&attr-copy-code}
      &scop attr-code attr-petrol-purse-o
      {&attr-copy-code}
      &scop attr-code attr-need-auth-o
      {&attr-copy-code}
      &scop attr-code attr-gds-margins-o
      {&attr-copy-code}
      &scop attr-code attr-proprietor-o
      {&attr-copy-code}
      &scop attr-code attr-fbr-cost-rubl
      {&attr-copy-code}
      &scop attr-code attr-no-income-goods
      {&attr-copy-code}
      &scop attr-code attr-taracode-o
      {&attr-copy-code}
      &scop attr-code attr-calories-o
      {&attr-copy-code}
      &scop attr-code attr-protein-o
      {&attr-copy-code}
      &scop attr-code attr-fat-o
      {&attr-copy-code}
      &scop attr-code attr-carbohydrate-o
      {&attr-copy-code}
      &scop attr-code attr-doc-tickets-o
      {&attr-copy-code}
      &scop attr-code attr-normal-wastage-o
      {&attr-copy-code}
      &scop attr-code attr-dop-alt-name-o
      {&attr-copy-code}
      &scop attr-code attr-dt-seasons
      {&attr-copy-code}
      &scop attr-code attr-change-dt-seasons
      {&attr-copy-code}
      &scop attr-code attr-mark-collect-type
      {&attr-copy-code}

      /* сюда добавлять новые параметры атрибутов товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1",  p-code ).
      end.
    end.
  end.
end procedure.


/* pop-up меню при ручном редактировании */

procedure gdsoattr-manual-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-scales-code-o
      {&attr-manual-edit-code}
      &scop attr-code attr-gds-margins-o
      {&attr-manual-edit-code}
      &scop attr-code attr-free-price-o
      {&attr-manual-edit-code}
      &scop attr-code attr-sum-grp-o
      {&attr-manual-edit-code}
      &scop attr-code attr-increase-pc-o
      {&attr-manual-edit-code}
      &scop attr-code attr-min-zapas-o
      {&attr-manual-edit-code}
      &scop attr-code attr-round-method-o
      {&attr-manual-edit-code}
      &scop attr-code attr-petrol-purse-o
      {&attr-manual-edit-code}
      &scop attr-code attr-need-auth-o
      {&attr-manual-edit-code}
      &scop attr-code attr-gds-margins-o
      {&attr-manual-edit-code}
      &scop attr-code attr-proprietor-o
      {&attr-manual-edit-code}
      &scop attr-code attr-fbr-cost-rubl
      {&attr-manual-edit-code}
      &scop attr-code attr-taracode-o
      {&attr-manual-edit-code}
      &scop attr-code attr-calories-o
      {&attr-manual-edit-code}
      &scop attr-code attr-protein-o
      {&attr-manual-edit-code}
      &scop attr-code attr-fat-o
      {&attr-manual-edit-code}
      &scop attr-code attr-carbohydrate-o
      {&attr-manual-edit-code}
      &scop attr-code attr-doc-tickets-o
      {&attr-manual-edit-code}
      &scop attr-code attr-normal-wastage-o
      {&attr-manual-edit-code}
      &scop attr-code attr-dop-alt-name-o
      {&attr-manual-edit-code}
      &scop attr-code attr-dt-seasons
      {&attr-manual-edit-code}



      /* сюда добавлять новые параметры атрибутов товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure gdsoattr-batch-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-scales-code-o
      {&attr-batch-edit-code}
      &scop attr-code attr-gds-margins-o
      {&attr-batch-edit-code}
      &scop attr-code attr-free-price-o
      {&attr-batch-edit-code}
      &scop attr-code attr-sum-grp-o
      {&attr-batch-edit-code}
      &scop attr-code attr-increase-pc-o
      {&attr-batch-edit-code}
      &scop attr-code attr-min-zapas-o
      {&attr-batch-edit-code}
      &scop attr-code attr-round-method-o
      {&attr-batch-edit-code}
      &scop attr-code attr-petrol-purse-o
      {&attr-batch-edit-code}
      &scop attr-code attr-need-auth-o
      {&attr-batch-edit-code}
      &scop attr-code attr-gds-margins-o
      {&attr-batch-edit-code}
      &scop attr-code attr-proprietor-o
      {&attr-batch-edit-code}
      &scop attr-code attr-fbr-cost-rubl
      {&attr-batch-edit-code}
      &scop attr-code attr-no-income-goods
      {&attr-batch-edit-code}
      &scop attr-code attr-taracode-o
      {&attr-batch-edit-code}
      &scop attr-code attr-calories-o
      {&attr-batch-edit-code}
      &scop attr-code attr-protein-o
      {&attr-batch-edit-code}
      &scop attr-code attr-fat-o
      {&attr-batch-edit-code}
      &scop attr-code attr-carbohydrate-o
      {&attr-batch-edit-code}
      &scop attr-code attr-doc-tickets-o
      {&attr-batch-edit-code}
      &scop attr-code attr-normal-wastage-o
      {&attr-batch-edit-code}
      &scop attr-code attr-dop-alt-name-o
      {&attr-batch-edit-code}
      &scop attr-code attr-dt-seasons
      {&attr-batch-edit-code}
      &scop attr-code attr-change-dt-seasons
      {&attr-batch-edit-code}
      &scop attr-code attr-mark-collect-type
      {&attr-batch-edit-code}

      /* сюда добавлять новые параметры атрибутов товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure gds-obj-sum-grps :

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE rid-list as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.

  do
  on error undo, return error
  :
    find first buf_sum-grp no-lock where
               buf_sum-grp.grp-code = integer(p-value) no-error .
    if avail buf_sum-grp then do:
      assign
      rid-list = string(recid(buf_sum-grp))
      .
    end.
    run ref/sum-grps.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_sum-grp no-lock where
                 recid(buf_sum-grp) = integer(entry(1, rid-list)) no-error .
      if not avail buf_sum-grp then return error.
      assign
      p-value = string(buf_sum-grp.grp-code, "999")
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.

end procedure. /* gds-obj-sum-grps */


procedure gds-obj-init-increase-pc :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .
define output parameter p-value as character no-undo .
define buffer buf_goods for ub.goods.

  do
  on error undo, return error
  :
    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error .
    if avail buf_goods then
    assign
    p-value = string(buf_goods.increase-pc)
    .
  end.

end procedure. /* gds-obj-init-increase-pc */


procedure gds-obj-round-method :
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/r-method.w (input-output v-value) no-error .
    if p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* gds-obj-round-method */

procedure gds-obj-taracode :

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .

define output parameter p-setted as logical no-undo .
DEFINE VARIABLE rid-list as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable par-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr.

  do
  on error undo, return error return-value
  :
    { gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
    /*найдем dflt-cd для объекта*/

    run adm/shattri.p (
      input "get":U
      ,input p-obj-type
      ,input p-obj-code
      ,input  {&attr-cd-sending}
      ,input  "dflt-cd":U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    IF not error-status:error then
    assign
    dflt-cd = v-value-character .

    find first buf_cash-desk-attr no-lock where
              buf_cash-desk-attr.obj-code = p-obj-code
         and  buf_cash-desk-attr.cash-num = 0
         and  buf_cash-desk-attr.pos-type = dflt-cd
         and buf_cash-desk-attr.attr-code = ('tara-ref':U  + {&delim-par} + p-value)
         and buf_cash-desk-attr.db-num  = v-obj-db-num  no-error .

    if avail buf_cash-desk-attr then do:
      assign
      rid-list = string(recid(buf_cash-desk-attr))
      .
    end.
    run ref/ncrtarac.w ( input parparentproc
                    ,input ? /*p-db-num*/
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input ? /*p-pos-type */
                    ,input ? /*p-cash-num*/
                    ,input "b-sel"
                    ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_cash-desk-attr no-lock where
                 recid(buf_cash-desk-attr) = integer(entry(1, rid-list)) no-error .
      if not avail buf_cash-desk-attr then return error.
      assign
      p-value = string(integer(entry(2, buf_cash-desk-attr.attr-code, {&delim-par}) ), "99")
      p-setted = yes
      .
    end.
    else p-setted = no.
  end.

end procedure. /* gds-obj-taracode */



procedure gds-obj-attr_check-ptrl-divis :
  define input parameter  p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input parameter  p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input parameter  p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define output parameter p-correct     as logical   no-undo .
  define output parameter p-error-code  as character no-undo .

  define buffer buf_goods for ub.goods.

  define variable v-is-petrolium as logical no-undo .
  define variable v-is-pieces    as logical no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
      return error substitute("(Еще) Нет товара с кодом &1, невозможно выполнить проверку корректности установки атрибута"
                              , p-gds-code).
    end.
    { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-is-petrolium v-is-pieces no-error }
    if error-status:error then do:
      assign
      p-error-code =  substitute("&1 &2", error-status:get-message(1) , return-value ).
      return.
    end.
    if not v-is-petrolium then do:
      assign
      p-error-code = substitute("Товар-топливо должен иметь топливную единицу измерения для задания норм естественной убыли для топлива").
      return p-error-code.
    end.
    if v-is-pieces then do:
      assign
      p-error-code = substitute("Товар-топливо должен иметь дробную единицу измерения для задания норм естественной убыли для топлива").
      return p-error-code.
    end.
    assign
    p-correct = yes.
  end.

end procedure. /* gds-obj-attr_check-ptrl-divis */


/* ################## */
/*АТРИБУТЫ ТОВАРА ДЛЯ ЗАКАЗ НА ОБЪЕКТЕ/фирме*/

/*ПОКА НЕТ АТРИБУТОВ ДЛЯ ФИРМЫ - obj-type = {&cmp}!!!!*/

/* Корр.коэфф для расчета заказов */
&scop type-attr-corrcoeff-po {&type-dec}
&scop format-attr-corrcoeff-po  ">>9.99"
&scop label-attr-corrcoeff-po   "Корр.коэфф для расчета заказов"
&scop tooltip-attr-corrcoeff-po   "Корректирующий коэффициент для расчета кол-ва в заказах ОБЪЕКТ-ПОСТАВЩИК"
&scop user-can-edit-attr-corrcoeff-po  true
&scop output-display-attr-corrcoeff-po  false
&scop other-attr-corrcoeff-po  "init-value=1"
&scop copy-attr-corrcoeff-po  false
&scop manual-edit-attr-corrcoeff-po  0
&scop batch-edit-attr-corrcoeff-po  0

/* служебный атрибут  дата изменения НА СТАТУС НА ВЫВОД ИЗ АССОРТ*/
&scop type-gopattr-CorrIztDel {&type-date}
&scop format-gopattr-CorrIztDel  "99/99/9999"
&scop label-gopattr-CorrIztDel   "Дата НА ВЫВОД ИЗ АССОРТ"
&scop tooltip-gopattr-CorrIztDel   "Дата простановки статуса НА ВЫВОД ИЗ АССОРТИМЕНТА"
&scop user-can-edit-gopattr-CorrIztDel  false
&scop output-display-gopattr-CorrIztDel  false
&scop other-gopattr-CorrIztDel  ""
&scop copy-gopattr-CorrIztDel  false
&scop manual-edit-gopattr-CorrIztDel  0
&scop batch-edit-gopattr-CorrIztDel  0


/* сюда добавлять новые параметры атрибутов товаров ДЛЯ ЗАКАЗА на объекте.фирме */
/*init-value надо задавать ОБЯЗАТЕЛЬНО - ТАК ФОРМА УСТРОЕНА!!!!*/


&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-copy-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-copy = ~{&copy-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdspoatr-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    case p-code :
      &scop attr-code attr-corrcoeff-po
      {&attr-temp-full-code}
      &scop attr-code gopattr-corriztdel
      {&attr-temp-full-code}




       /* сюда добавлять новые параметры атрибутов товаров на объекте ОВ*/
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара для ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdspoatr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-corrcoeff-po
      {&attr-temp-code}
      &scop attr-code gopattr-corriztdel
      {&attr-temp-code}




      /* сюда добавлять новые параметры атрибутов товаров на объекте для ЗАКАЗОВ*/
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара для ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure gdspoatr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define output parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable jj as integer no-undo .
    define variable v-found as logical no-undo .

    run gdspoatr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-obj-prop-attr no-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code AND
               buf_gds-obj-prop-attr.obj-type  = p-obj-type AND
               buf_gds-obj-prop-attr.obj-code  = p-obj-code AND
               buf_gds-obj-prop-attr.attr-code = p-code
      no-error .
    if avail buf_gds-obj-prop-attr then do:
      assign
        p-value =  buf_gds-obj-prop-attr.attr-value
      .
    end.
    else do:
      do jj = 1 to num-entries(v-other, {&slash-char}):
        if entry(1, entry(jj, v-other, {&slash-char}), "=":U) = "init-value":U then do:
          assign
          p-value = string(entry(2, entry(jj, v-other, {&slash-char}), "=":U))
          v-found = yes
          .
        end.
      end. /*jj*/
      if not v-found then do:
        assign
        p-value = if p-type = {&type-log} then "no":U else ""
        .
      end.
    end.
  end.

end procedure.


procedure gdspoatr-write :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .

    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .
    define buffer lock_gds-obj-prop-attr for ub.gds-obj-prop-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdspoatr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    /*
    воможный вариант локировки с помощью дополнительного атрибута
    find first lock_gds-obj-prop-attr exclusive-lock where
               lock_gds-obj-prop-attr.gds-code  = p-gds-code AND
               lock_gds-obj-prop-attr.obj-type  = p-obj-type AND
              lock_gds-obj-prop-attr.obj-code  = p-obj-code AND
              lock_gds-obj-prop-attr.attr-code = {&attr-lock} no-error no-wait .
    if locked lock_gds-obj-prop-attr then do:
      undo, return error {&attr-lock}.
    end.
    if not available lock_gds-obj-prop-attr
    and not locked lock_gds-obj-prop-attr
    then do:
      create lock_gds-obj-prop-attr.
      assign
      lock_gds-obj-prop-attr.gds-code  = p-gds-code
      lock_gds-obj-prop-attr.obj-type  = p-obj-type
      lock_gds-obj-prop-attr.obj-code  = p-obj-code
      lock_gds-obj-prop-attr.attr-code = {&attr-lock}
      no-error
      .
    end.
    find current lock_gds-obj-prop-attr share-lock.
    */
    find first buf_gds-obj-prop-attr exclusive-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code
           AND buf_gds-obj-prop-attr.obj-type  = p-obj-type
           AND buf_gds-obj-prop-attr.obj-code  = p-obj-code
           AND buf_gds-obj-prop-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-prop-attr then do:
      create buf_gds-obj-prop-attr .
      assign
        buf_gds-obj-prop-attr.gds-code  = p-gds-code
        buf_gds-obj-prop-attr.obj-type  = p-obj-type
        buf_gds-obj-prop-attr.obj-code  = p-obj-code
        buf_gds-obj-prop-attr.attr-code = p-code
        buf_gds-obj-prop-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_gds-obj-prop-attr.attr-value = p-value no-error.
  end.

end procedure.


procedure gdspoatr-exist :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdspoatr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-obj-prop-attr no-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code
           AND buf_gds-obj-prop-attr.obj-type  = p-obj-type
           AND buf_gds-obj-prop-attr.obj-code  = p-obj-code
           AND buf_gds-obj-prop-attr.attr-code = p-code no-error .
    if available buf_gds-obj-prop-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure gdspoatr-delete :

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
    define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gdspoatr-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-obj-prop-attr exclusive-lock where
               buf_gds-obj-prop-attr.gds-code  = p-gds-code
           AND buf_gds-obj-prop-attr.obj-type  = p-obj-type
           AND buf_gds-obj-prop-attr.obj-code  = p-obj-code
           AND buf_gds-obj-prop-attr.attr-code = p-code no-error .
    if not available buf_gds-obj-prop-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_gds-obj-prop-attr.
       P-DELETED = YES.
    END.
  end.

end procedure.

procedure gdspoatr-copy :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-copy           as logical   no-undo . /* копируется при копировании товара - если включены соответ настройки */

    case p-code :
      &scop attr-code attr-corrcoeff-po
      {&attr-copy-code}
      &scop attr-code gopattr-corriztdel
      {&attr-copy-code}



      /* сюда добавлять новые параметры атрибутов товаров ДЛЯ ЗАКАЗА на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара ДЛЯ ЗАКАЗОВ на объекте/фирме &1",  p-code ).
      end.
    end.
  end.
end procedure.


/* pop-up меню при ручном редактировании */

procedure gdspoatr-manual-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-corrcoeff-po
      {&attr-manual-edit-code}
      &scop attr-code gopattr-corriztdel
      {&attr-manual-edit-code}



      /* сюда добавлять новые параметры атрибутов товаров на объекте ДЛЯ ЗАКАЗОВ */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара ДЛЯ ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure gdspoatr-batch-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code attr-corrcoeff-po
      {&attr-batch-edit-code}
      &scop attr-code gopattr-corriztdel
      {&attr-batch-edit-code}


      /* сюда добавлять новые параметры атрибутов товаров ДЛЯ ЗАКАЗОВ на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут товара ДЛЯ ЗАКАЗОВ на объекте/фирме &1", p-code ).
      end.
    end.
  end.
end procedure.

/* ################## */
/* атрибуты баз данных */

/* Наличие расписания отправки новостей для БД */
&scop type-attr-schedule-nws {&type-log}
&scop format-attr-schedule-nws "+/-"
&scop label-attr-schedule-nws "Расписание новостей для БД"
&scop tooltip-attr-schedule-nws "Составлено ли расписание отправки новостей для базы данных"
&scop user-can-edit-attr-schedule-nws false
&scop output-display-attr-schedule-nws true
&scop other-attr-schedule-nws '':u
&scop news-attr-schedule-nws no
&scop manual-edit-attr-schedule-nws 0
&scop batch-edit-attr-schedule-nws 0

/* Наличие расписания расчета архивов для БД */
&scop type-attr-schedule-arc {&type-log}
&scop format-attr-schedule-arc "+/-"
&scop label-attr-schedule-arc "Расписание расчета архивов для БД"
&scop tooltip-attr-schedule-arc "Составлено ли расписание расчета архивов для базы данных"
&scop user-can-edit-attr-schedule-arc false
&scop output-display-attr-schedule-arc true
&scop other-attr-schedule-arc '':u
&scop news-attr-schedule-arc no
&scop manual-edit-attr-schedule-arc 0
&scop batch-edit-attr-schedule-arc 0

/* Наличие расписания экспорта для БД */
&scop type-attr-schedule-exp {&type-log}
&scop format-attr-schedule-exp "+/-"
&scop label-attr-schedule-exp "Расписание экспорта для БД"
&scop tooltip-attr-schedule-exp "Составлено ли расписание экспорта для базы данных"
&scop user-can-edit-attr-schedule-exp false
&scop output-display-attr-schedule-exp true
&scop other-attr-schedule-exp '':u
&scop news-attr-schedule-exp no
&scop manual-edit-attr-schedule-exp 0
&scop batch-edit-attr-schedule-exp 0

/* Наличие расписания экспорта для БД */
&scop type-attr-schedule-oxml {&type-log}
&scop format-attr-schedule-oxml "+/-"
&scop label-attr-schedule-oxml "Расписание OpenXML для БД"
&scop tooltip-attr-schedule-oxml "Составлено ли расписание OpenXML для базы данных"
&scop user-can-edit-attr-schedule-oxml false
&scop output-display-attr-schedule-oxml true
&scop other-attr-schedule-oxml '':u
&scop news-attr-schedule-oxml no
&scop manual-edit-attr-schedule-oxml 0
&scop batch-edit-attr-schedule-oxml 0

/* Необходимость формирования нового пакета(ов) для БД */
&scop type-attr-need-gen-new-pack {&type-log}
&scop format-attr-need-gen-new-pack "+/-"
&scop label-attr-need-gen-new-pack "Необходимость формирования нового пакета(ов) для БД"
&scop tooltip-attr-need-gen-new-pack "Необходимо ли формировать новый пакет(ы) для базы данных"
&scop user-can-edit-attr-need-gen-new-pack false
&scop output-display-attr-need-gen-new-pack true
&scop other-attr-need-gen-new-pack '':u
&scop news-attr-need-gen-new-pack no
&scop manual-edit-attr-need-gen-new-pack 0
&scop batch-edit-attr-need-gen-new-pack 0

/* Последний ключ с которым выгружалась БД */
&scop type-attr-last-unload-db-key {&type-char}
&scop format-attr-last-unload-db-key "X(12)"
&scop label-attr-last-unload-db-key "Ключ с которым последний раз выгружали БД"
&scop tooltip-attr-last-unload-db-key "Ключ с которым последний раз выгружали БД"
&scop user-can-edit-attr-last-unload-db-key false
&scop output-display-attr-last-unload-db-key true
&scop other-attr-last-unload-db-key '':u
&scop news-attr-last-unload-db-key no
&scop manual-edit-attr-last-unload-db-key 0
&scop batch-edit-attr-last-unload-db-key 0

/* Наличие расписания экспорта для БД */
&scop type-attr-schedule-cdimp {&type-log}
&scop format-attr-schedule-cdimp "+/-"
&scop label-attr-schedule-cdimp "Расписание импорта через кассы для БД"
&scop tooltip-attr-schedule-cdimp "Составлено ли расписание импорта через кассы ИМПОРТА для базы данных"
&scop user-can-edit-attr-schedule-cdimp false
&scop output-display-attr-schedule-cdimp true
&scop other-attr-schedule-cdimp '':u
&scop news-attr-schedule-cdimp no
&scop manual-edit-attr-schedule-cdimp 0
&scop batch-edit-attr-schedule-cdimp 0

/* Наличие расписания приема информации с кассы */
&scop type-attr-schedule-getcd {&type-log}
&scop format-attr-schedule-getcd "+/-"
&scop label-attr-schedule-getcd "Расписание получения информации с касс для БД"
&scop tooltip-attr-schedule-getcd "Составлено ли расписание получения информации с касс для базы данных"
&scop user-can-edit-attr-schedule-getcd false
&scop output-display-attr-schedule-getcd true
&scop other-attr-schedule-getcd '':u
&scop news-attr-schedule-getcd no
&scop manual-edit-attr-schedule-getcd 0
&scop batch-edit-attr-schedule-getcd 0

/* Наличие расписания обработки документов продаж */
&scop type-attr-schedule-sale {&type-log}
&scop format-attr-schedule-sale "+/-"
&scop label-attr-schedule-sale "Расписание обработки документов продаж для БД"
&scop tooltip-attr-schedule-sale "Составлено ли расписание обработки документов продаж для базы данных"
&scop user-can-edit-attr-schedule-sale false
&scop output-display-attr-schedule-sale true
&scop other-attr-schedule-sale '':u
&scop news-attr-schedule-sale no
&scop manual-edit-attr-schedule-sale 0
&scop batch-edit-attr-schedule-sale 0

/* Наличие расписания запуска отчетов для БД */
&scop type-attr-schedule-suz {&type-log}
&scop format-attr-schedule-suz "+/-"
&scop label-attr-schedule-suz "Расписание запуска отчетов для БД"
&scop tooltip-attr-schedule-suz "Составлено ли расписание запуска отчетов для базы данных"
&scop user-can-edit-attr-schedule-suz false
&scop output-display-attr-schedule-suz true
&scop other-attr-schedule-suz '':u
&scop news-attr-schedule-suz no
&scop manual-edit-attr-schedule-suz 0
&scop batch-edit-attr-schedule-suz 0

/* Наличие расписания обмена с ФГИС Меркурий для БД */
&scop type-attr-schedule-merc {&type-log}
&scop format-attr-schedule-merc "+/-"
&scop label-attr-schedule-merc "Расписание обмена с ФГИС Меркурий для БД"
&scop tooltip-attr-schedule-merc "Составлено ли расписание обмена с ФГИС Меркурий для базы данных"
&scop user-can-edit-attr-schedule-merc false
&scop output-display-attr-schedule-merc true
&scop other-attr-schedule-merc '':u
&scop news-attr-schedule-merc no
&scop manual-edit-attr-schedule-merc 0
&scop batch-edit-attr-schedule-merc 0

/* Наличие расписания мониторинга HDD для БД */
&scop type-attr-schedule-hdd {&type-log}
&scop format-attr-schedule-hdd "+/-"
&scop label-attr-schedule-hdd "Расписание мониторинга HDD для БД"
&scop tooltip-attr-schedule-hdd "Составлено ли расписание мониторинга HDD для базы данных"
&scop user-can-edit-attr-schedule-hdd false
&scop output-display-attr-schedule-hdd true
&scop other-attr-schedule-hdd '':u
&scop news-attr-schedule-hdd no
&scop manual-edit-attr-schedule-hdd 0
&scop batch-edit-attr-schedule-hdd 0

/* Наличие расписания обмена с ИС МОТП для БД */
&scop type-attr-schedule-motp {&type-log}
&scop format-attr-schedule-motp "+/-"
&scop label-attr-schedule-motp "Расписание обмена с ИС МОТП для БД"
&scop tooltip-attr-schedule-motp "Составлено ли расписание обмена с ИС МОТП для базы данных"
&scop user-can-edit-attr-schedule-motp false
&scop output-display-attr-schedule-motp true
&scop other-attr-schedule-motp '':u
&scop news-attr-schedule-motp no
&scop manual-edit-attr-schedule-motp 0
&scop batch-edit-attr-schedule-motp 0

/* Наличие расписания обмена с ИС Диадок для БД */
&scop type-attr-schedule-diadoc {&type-log}
&scop format-attr-schedule-diadoc "+/-"
&scop label-attr-schedule-diadoc "Расписание обмена с Диадок для БД"
&scop tooltip-attr-schedule-diadoc "Составлено ли расписание обмена с Диадок для базы данных"
&scop user-can-edit-attr-schedule-diadoc false
&scop output-display-attr-schedule-diadoc true
&scop other-attr-schedule-diadoc '':u
&scop news-attr-schedule-diadoc no
&scop manual-edit-attr-schedule-diadoc 0
&scop batch-edit-attr-schedule-diadoc 0

/* Наличие расписания выгрузки в ИС ПМ для БД */
&scop type-attr-schedule-isPM {&type-log}
&scop format-attr-schedule-isPM "+/-"
&scop label-attr-schedule-isPM "Расписание выгрузки в ИС ПМ для БД"
&scop tooltip-attr-schedule-isPM "Составлено ли расписание выгрузки в ИС ПМ для базы данных"
&scop user-can-edit-attr-schedule-isPM false
&scop output-display-attr-schedule-isPM true
&scop other-attr-schedule-isPM '':u
&scop news-attr-schedule-isPM no
&scop manual-edit-attr-schedule-isPM 0
&scop batch-edit-attr-schedule-isPM 0

 /* Дата по которую усечены документы по БД в ГБД */
&scop type-attr-cut-date {&type-date}
&scop format-attr-cut-date "99.99.9999"
&scop label-attr-cut-date "Дата по которую усечены документы по БД в ГБД"
&scop tooltip-attr-cut-date "Дата по которую усечены документы по БД в ГБД"
&scop user-can-edit-attr-cut-date false
&scop output-display-attr-cut-date true
&scop other-attr-cut-date '':u
&scop news-attr-cut-date yes
&scop manual-edit-attr-cut-date 0
&scop batch-edit-attr-cut-date 0

 /* Дата по которую усечены финансовые документы по БД в ГБД */
&scop type-attr-cut-fin-date {&type-date}
&scop format-attr-cut-fin-date "99.99.9999"
&scop label-attr-cut-fin-date "Дата по которую усечены финансовые документы по БД в ГБД"
&scop tooltip-attr-cut-fin-date "Дата по которую усечены финансовые документы по БД в ГБД"
&scop user-can-edit-attr-cut-fin-date false
&scop output-display-attr-cut-fin-date true
&scop other-attr-cut-fin-date '':u
&scop news-attr-cut-fin-date yes
&scop manual-edit-attr-cut-fin-date 0
&scop batch-edit-attr-cut-fin-date 0

 /* БД выгружена после усечения документов по ней в ГБД */
&scop type-attr-unload-after-cut {&type-log}
&scop format-attr-unload-after-cut "+/-"
&scop label-attr-unload-after-cut "БД выгружена после усечения документов по ней в ГБД"
&scop tooltip-attr-unload-after-cut "БД выгружена после усечения документов по ней в ГБД"
&scop user-can-edit-attr-unload-after-cut false
&scop output-display-attr-unload-after-cut true
&scop other-attr-unload-after-cut '':u
&scop news-attr-unload-after-cut yes
&scop manual-edit-attr-unload-after-cut 0
&scop batch-edit-attr-unload-after-cut 0

 /* Список БД в которых усекаются документы */
&scop type-attr-cut-db-list {&type-char}
&scop format-attr-cut-db-list "X(256)"
&scop label-attr-cut-db-list "Список БД в которых усекаются документы"
&scop tooltip-attr-cut-db-list "Список БД в которых усекаются документы"
&scop user-can-edit-attr-cut-db-list false
&scop output-display-attr-cut-db-list true
&scop other-attr-cut-db-list '':u
&scop news-attr-cut-db-list no
&scop manual-edit-attr-cut-db-list 0
&scop batch-edit-attr-cut-db-list 0

/* Наличие расписания обработки экспорта импорта в КЛИЕНТ-БАНК */
&scop type-attr-schedule-cbnk {&type-log}
&scop format-attr-schedule-cbnk "+/-"
&scop label-attr-schedule-cbnk "Расписание эксп/имп в КЛИЕНТ-БАНК"
&scop tooltip-attr-schedule-cbnk "Составлено ли расписание для эксп/имп в КЛИЕНТ-БАНК"
&scop user-can-edit-attr-schedule-cbnk false
&scop output-display-attr-schedule-cbnk true
&scop other-attr-schedule-cbnk '':u
&scop news-attr-schedule-cbnk no
&scop manual-edit-attr-schedule-cbnk 0
&scop batch-edit-attr-schedule-cnbk 0


/* Расчет складского архива по товарам запрещен */
&scop type-attr-db-arh-disable {&type-log}
&scop format-attr-db-arh-disable "+/-"
&scop label-attr-db-arh-disable "Расчет складского архива по товарам запрещен"
&scop tooltip-attr-db-arh-disable "Расчет складского архива по товарам запрещен"
&scop user-can-edit-attr-db-arh-disable false
&scop output-display-attr-db-arh-disable true
&scop other-attr-db-arh-disable '':u
&scop news-attr-db-arh-disable no
&scop manual-edit-attr-db-arh-disable 0
&scop batch-edit-attr-db-arh-disable 0


/* Расчет складского архива по поставщикам запрещен */
&scop type-attr-db-ahsp-disable {&type-log}
&scop format-attr-db-ahsp-disable "+/-"
&scop label-attr-db-ahsp-disable "Расчет складского архива по поставщикам запрещен"
&scop tooltip-attr-db-ahsp-disable "Расчет складского архива по поставщикам запрещен"
&scop user-can-edit-attr-db-ahsp-disable false
&scop output-display-attr-db-ahsp-disable true
&scop other-attr-db-ahsp-disable '':u
&scop news-attr-db-ahsp-disable no
&scop manual-edit-attr-db-ahsp-disable 0
&scop batch-edit-attr-db-ahsp-disable 0


/* Расчет складского архива по типам приобретения запрещен */
&scop type-attr-db-aht-disable {&type-log}
&scop format-attr-db-aht-disable "+/-"
&scop label-attr-db-aht-disable "Расчет складского архива по типам приобретения запрещен"
&scop tooltip-attr-db-aht-disable "Расчет складского архива по типам приобретения запрещен"
&scop user-can-edit-attr-db-aht-disable false
&scop output-display-attr-db-aht-disable true
&scop other-attr-db-aht-disable '':u
&scop news-attr-db-aht-disable no
&scop manual-edit-attr-db-aht-disable 0
&scop batch-edit-attr-db-aht-disable 0


/* Наличие расписания обработки произвольных задач */
&scop type-attr-schedule-free {&type-log}
&scop format-attr-schedule-free "+/-"
&scop label-attr-schedule-free "Расписание произвольных задач"
&scop tooltip-attr-schedule-free "Составлено ли расписание произвольных задач"
&scop user-can-edit-attr-schedule-free false
&scop output-display-attr-schedule-free true
&scop other-attr-schedule-free '':u
&scop news-attr-schedule-free no
&scop manual-edit-attr-schedule-free 0
&scop batch-edit-attr-schedule-free 0

 /* Номер последней выгрузки в Oracle Retail */
&scop type-attr-ora-exp-seq {&type-int}
&scop format-attr-ora-exp-seq "999999999"
&scop label-attr-ora-exp-seq "Номер последней выгрузки в Oracle Retail"
&scop tooltip-attr-ora-exp-seq "Номер последней выгрузки в Oracle Retail"
&scop user-can-edit-attr-ora-exp-seq false
&scop output-display-attr-ora-exp-seq true
&scop other-attr-ora-exp-seq '':u
&scop news-attr-ora-exp-seq no
&scop manual-edit-attr-ora-exp-seq 0
&scop batch-edit-attr-ora-exp-seq 0


/* Номер сообщения видеонаблюдения */
&scop type-attr-mess-id-video {&type-log}
&scop format-attr-mess-id-video "+/-"
&scop label-attr-mess-id-video "Номер сообщения видеонаблюдения"
&scop tooltip-attr-mess-id-video "Номер сообщения видеонаблюдения"
&scop user-can-edit-attr-mess-id-video false
&scop output-display-attr-mess-id-video true
&scop other-attr-mess-id-video '':u
&scop news-attr-mess-id-video no
&scop manual-edit-attr-mess-id-video 0
&scop batch-edit-attr-mess-id-video 0


/* Точка интеграции ERPRN */
&scop type-attr-int-point {&type-char}
&scop format-attr-int-point "+/-"
&scop label-attr-int-point "Точка интеграции ERPRN"
&scop tooltip-attr-int-point "Точка интеграции ERPRN"
&scop user-can-edit-attr-int-point false
&scop output-display-attr-int-point true
&scop other-attr-int-point '':u
&scop news-attr-int-point yes
&scop manual-edit-attr-int-point 0
&scop batch-edit-attr-int-point 0

 /* Версия справочников */
&scop type-attr-ver-code {&type-int}
&scop format-attr-ver-code "999999999"
&scop label-attr-ver-code "Версия справочников"
&scop tooltip-attr-ver-code "Версия справочников"
&scop user-can-edit-attr-ver-code false
&scop output-display-attr-ver-code true
&scop other-attr-ver-code '':u
&scop news-attr-ver-code no
&scop manual-edit-attr-ver-code 0
&scop batch-edit-attr-ver-code 0

 /* Версия метаданных */
&scop type-attr-ver-met {&type-int}
&scop format-attr-ver-met "999999999"
&scop label-attr-ver-met "Версия метаданных"
&scop tooltip-attr-ver-met "Версия метаданных"
&scop user-can-edit-attr-ver-met false
&scop output-display-attr-ver-met true
&scop other-attr-ver-met '':u
&scop news-attr-ver-met no
&scop manual-edit-attr-ver-met 0
&scop batch-edit-attr-ver-met 0


/* Исторический код объекта */
&scop type-attr-hist-code {&type-char}
&scop format-attr-hist-code "x(50)"
&scop label-attr-hist-code "Исторический код объекта"
&scop tooltip-attr-hist-code "Исторический код объекта"
&scop user-can-edit-attr-hist-code false
&scop output-display-attr-hist-code true
&scop other-attr-hist-code '':u
&scop news-attr-hist-code yes
&scop manual-edit-attr-hist-code 0
&scop batch-edit-attr-hist-code 0

/* Историческое наименование объекта */
&scop type-attr-hist-name {&type-char}
&scop format-attr-hist-name "x(50)"
&scop label-attr-hist-name "Историческое наименование объекта"
&scop tooltip-attr-hist-name "Историческое наименование объекта"
&scop user-can-edit-attr-hist-name false
&scop output-display-attr-hist-name true
&scop other-attr-hist-name '':u
&scop news-attr-hist-name yes
&scop manual-edit-attr-hist-name 0
&scop batch-edit-attr-hist-name 0

&scop type-attr-ASIip {&type-char}
&scop format-attr-ASIip "X(20)"
&scop label-attr-ASIip "АСИ IP"
&scop tooltip-attr-ASIip "АСИ IP"
&scop user-can-edit-attr-ASIip false
&scop output-display-attr-ASIip true
&scop other-attr-ASIip '':u
&scop news-attr-ASIip no
&scop manual-edit-attr-ASIip 0
&scop batch-edit-attr-ASIip 0

&scop type-attr-ASIPort {&type-char}
&scop format-attr-ASIPort "X(12)"
&scop label-attr-ASIPort "АСИ Port"
&scop tooltip-attr-ASIPort "АСИ port"
&scop user-can-edit-attr-ASIPort false
&scop output-display-attr-ASIPort true
&scop other-attr-ASIPort '':u
&scop news-attr-ASIPort no
&scop manual-edit-attr-ASIPort 0
&scop batch-edit-attr-ASIPort 0

&scop type-attr-ASItype {&type-char}
&scop format-attr-ASItype "X(12)"
&scop label-attr-ASItype "АСИ Type"
&scop tooltip-attr-ASItype "АСИ Type"
&scop user-can-edit-attr-ASItype false
&scop output-display-attr-ASItype true
&scop other-attr-ASItype '':u
&scop news-attr-ASItype no
&scop manual-edit-attr-ASItype 0
&scop batch-edit-attr-ASItype 0

 /* Регион */
&scop type-attr-reg-code {&type-int}
&scop format-attr-reg-code "999999999"
&scop label-attr-reg-code "Регион"
&scop tooltip-attr-reg-code "Регион"
&scop user-can-edit-attr-reg-code false
&scop output-display-attr-reg-code true
&scop other-attr-reg-code '':u
&scop news-attr-reg-code true
&scop manual-edit-attr-reg-code 0
&scop batch-edit-attr-reg-code 0

 /* Время последней синхронизации обмена СПН */
&scop type-attr-last-nws-sync {&type-char}
&scop format-attr-last-nws-sync "X(60)"
&scop label-attr-last-nws-sync "Время последней синхронизации обмена СПН"
&scop tooltip-attr-last-nws-sync "Время последней синхронизации обмена СПН"
&scop user-can-edit-attr-last-nws-sync false
&scop output-display-attr-last-nws-sync false
&scop other-attr-last-nws-sync '':u
&scop news-attr-last-nws-sync no
&scop manual-edit-attr-last-nws-sync 0
&scop batch-edit-attr-last-nws-sync 0
/* сюда добавлять новые параметры атрибутов баз данных */

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure db-attr-code :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-schedule-nws
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-merc
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-hdd
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-motp
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-diadoc
      {&attr-temp-full-code}
      &scop attr-code attr-ver-met
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-isPM
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-arc
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-exp
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-oxml
      {&attr-temp-full-code}
      &scop attr-code attr-need-gen-new-pack
      {&attr-temp-full-code}
      &scop attr-code attr-last-unload-db-key
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-getcd
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-sale
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-suz
      {&attr-temp-full-code}
      &scop attr-code attr-cut-date
      {&attr-temp-full-code}
      &scop attr-code attr-cut-fin-date
      {&attr-temp-full-code}
      &scop attr-code attr-unload-after-cut
      {&attr-temp-full-code}
      &scop attr-code attr-cut-db-list
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-cbnk
      {&attr-temp-full-code}
      &scop attr-code attr-db-arh-disable
      {&attr-temp-full-code}
      &scop attr-code attr-db-ahsp-disable
      {&attr-temp-full-code}
      &scop attr-code attr-db-aht-disable
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-free
      {&attr-temp-full-code}
      &scop attr-code attr-ora-exp-seq
      {&attr-temp-full-code}
      &scop attr-code attr-mess-id-video
      {&attr-temp-full-code}
      &scop attr-code attr-int-point
      {&attr-temp-full-code}
      &scop attr-code attr-ver-code
      {&attr-temp-full-code}
      &scop attr-code attr-hist-code
      {&attr-temp-full-code}
      &scop attr-code attr-hist-name
      {&attr-temp-full-code}
      &scop attr-code attr-asiip
      {&attr-temp-full-code}
      &scop attr-code attr-asiport
      {&attr-temp-full-code}
      &scop attr-code attr-asitype
      {&attr-temp-full-code}
      &scop attr-code attr-reg-code
      {&attr-temp-full-code}
      &scop attr-code attr-last-nws-sync
      {&attr-temp-full-code}
      
      /* сюда добавлять новые параметры атрибутов баз данных */
      otherwise do:          
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure db-attr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-schedule-nws
      {&attr-temp-code}
      &scop attr-code attr-schedule-merc
      {&attr-temp-code}
      &scop attr-code attr-schedule-hdd
      {&attr-temp-code}
      &scop attr-code attr-schedule-motp
      {&attr-temp-code}
      &scop attr-code attr-schedule-diadoc
      {&attr-temp-code}
      &scop attr-code attr-ver-met
      {&attr-temp-code}
      &scop attr-code attr-schedule-isPM
      {&attr-temp-code}
      &scop attr-code attr-schedule-arc
      {&attr-temp-code}
      &scop attr-code attr-schedule-exp
      {&attr-temp-code}
      &scop attr-code attr-schedule-oxml
      {&attr-temp-code}
      &scop attr-code attr-need-gen-new-pack
      {&attr-temp-code}
      &scop attr-code attr-last-unload-db-key
      {&attr-temp-code}
      &scop attr-code attr-schedule-getcd
      {&attr-temp-code}
      &scop attr-code attr-schedule-sale
      {&attr-temp-code}
      &scop attr-code attr-schedule-suz
      {&attr-temp-code}
      &scop attr-code attr-cut-date
      {&attr-temp-code}
      &scop attr-code attr-cut-fin-date
      {&attr-temp-code}
      &scop attr-code attr-unload-after-cut
      {&attr-temp-code}
      &scop attr-code attr-cut-db-list
      {&attr-temp-code}
      &scop attr-code attr-schedule-cbnk
      {&attr-temp-code}
      &scop attr-code attr-db-arh-disable
      {&attr-temp-code}
      &scop attr-code attr-db-ahsp-disable
      {&attr-temp-code}
      &scop attr-code attr-db-aht-disable
      {&attr-temp-code}
      &scop attr-code attr-schedule-free
      {&attr-temp-code}
      &scop attr-code attr-ora-exp-seq
      {&attr-temp-code}
      &scop attr-code attr-mess-id-video
      {&attr-temp-code}
      &scop attr-code attr-int-point
      {&attr-temp-code}
      &scop attr-code attr-ver-code
      {&attr-temp-code}
      &scop attr-code attr-hist-code
      {&attr-temp-code}
      &scop attr-code attr-hist-name
      {&attr-temp-code}
      &scop attr-code attr-asiip
      {&attr-temp-code}
      &scop attr-code attr-asiport
      {&attr-temp-code}
      &scop attr-code attr-asitype
      {&attr-temp-code}
      &scop attr-code attr-reg-code
      {&attr-temp-code}
      &scop attr-code attr-last-nws-sync
      {&attr-temp-code}

      /* сюда добавлять новые параметры атрибутов баз данных */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure db-attr-value :

  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .

  do
  on error undo, return error
  :
    define buffer buf_db-attr for ub.db-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure db-attr-write :

  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .

  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.

    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.

end procedure.


procedure db-attr-exist :

  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure db-attr-delete :

  define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    define buffer buf_db-attr for ub.db-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run db-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure db-attr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-schedule-nws
      {&attr-news-code}
      &scop attr-code attr-schedule-merc
      {&attr-news-code}
      &scop attr-code attr-schedule-hdd
      {&attr-news-code}
      &scop attr-code attr-schedule-motp
      {&attr-news-code}
      &scop attr-code attr-schedule-diadoc
      {&attr-news-code}
      &scop attr-code attr-ver-met
      {&attr-news-code}
      &scop attr-code attr-schedule-isPM
      {&attr-news-code}
      &scop attr-code attr-schedule-arc
      {&attr-news-code}
      &scop attr-code attr-schedule-exp
      {&attr-news-code}
      &scop attr-code attr-schedule-oxml
      {&attr-news-code}
      &scop attr-code attr-need-gen-new-pack
      {&attr-news-code}
      &scop attr-code attr-last-unload-db-key
      {&attr-news-code}
      &scop attr-code attr-schedule-getcd
      {&attr-news-code}
      &scop attr-code attr-schedule-sale
      {&attr-news-code}
      &scop attr-code attr-schedule-suz
      {&attr-news-code}
      &scop attr-code attr-cut-date
      {&attr-news-code}
      &scop attr-code attr-cut-fin-date
      {&attr-news-code}
      &scop attr-code attr-unload-after-cut
      {&attr-news-code}
      &scop attr-code attr-cut-db-list
      {&attr-news-code}
      &scop attr-code attr-schedule-cbnk
      {&attr-news-code}
      &scop attr-code attr-db-arh-disable
      {&attr-news-code}
      &scop attr-code attr-db-ahsp-disable
      {&attr-news-code}
      &scop attr-code attr-db-aht-disable
      {&attr-news-code}
      &scop attr-code attr-schedule-free
      {&attr-news-code}
      &scop attr-code attr-ora-exp-seq
      {&attr-news-code}
      &scop attr-code attr-mess-id-video
      {&attr-news-code}
      &scop attr-code attr-int-point
      {&attr-news-code}
      &scop attr-code attr-hist-code
      {&attr-news-code}
      &scop attr-code attr-hist-name
      {&attr-news-code}
      &scop attr-code attr-asiip
      {&attr-news-code}
      &scop attr-code attr-asiport
      {&attr-news-code}
      &scop attr-code attr-asitype
      {&attr-news-code}
      &scop attr-code attr-reg-code
      {&attr-news-code}
      &scop attr-code attr-last-nws-sync
      {&attr-news-code}
      
      /* сюда добавлять новые параметры атрибутов баз данных */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.


/*секция pop-up меню при ручном редактировании */
procedure db-attr-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибутов баз данных */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure db-attr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибутов баз данных */
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code ).
      end.
    end.
  end.
end procedure.

/* проверяет, может ли быть установлен этому товару атрибут "Сезон ДТ" */
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code like ub.goods.gds-code     no-undo .
  define output parameter p-can-set  as   logical no-undo .

  define variable v-value as character no-undo .
  define variable v-type as character no-undo .

  run gds-attr-value in this-procedure (
    input p-gds-code
    ,input "fuel-type"
    ,output v-value
    ,output v-type) .
  p-can-set = v-value = "diesel".

end procedure.

/* alek проверяет, является ли код товара кодом сезона ДТ */
/* если да то опеределяем по нему код товара */
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     as   integer             no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .

  define buffer buf_code for ub.code.
  
  p-dt-code = 0.
  if can-find(first buf_code where
                  buf_code.code = string(p-code)
              and buf_code.parent = "DTSeasons") then
  do:
    p-dt-code = p-code.
    run gdsoattr-gds-code in this-procedure 
      ("dt-seasons", string(p-code), p-obj-type, p-obj-code, output p-gds-code).
    /* Если переданный код не привязан ни к одному товару на объекте, */
    /* то код товара и код Сезона ДТ возвращаем одинаковый */
    if p-gds-code = 0 then
      p-gds-code = p-code.
  end.
  else 
    p-gds-code = p-code.

end procedure.

procedure gds-obj-dt-seasons :

  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  
  define variable rid            as recid no-undo .
  define variable canSetDtSeason as logical no-undo.
  define variable gdsCode        like ub.gds-obj-attr.gds-code no-undo.
  define buffer buf_code       for ub.code.
  define buffer buf_goods      for ub.goods.

  run gds-attr_check-can-set-dt-seasons in this-procedure
    (p-gds-code, output canSetDtSeason).
  if not canSetDtSeason then
  do:
    find first buf_goods where
               buf_goods.gds-code = p-gds-code 
         no-lock no-error.
    message "Атрибут ~"Сезон ДТ~| может быть настроен только для дизельного топлива.~n"
            "Для товара " if available buf_goods then substitute("<&1 &2 &3>",buf_goods.gds-code, buf_goods.artic, buf_goods.gds-name) else ""
            "~nне установлен атрибут ~"Тип топлива~" в значении ~"ДТ~".~n"
            "В установке атрибута «Сезон ДТ» отказано." view-as alert-box.
    p-setted = no.
    return.
  end.

  do
  on error undo, return error
  :
    run ref/dtseasons.p
      (input  parparentproc
      , p-gds-code
      ,output rid
      ) no-error.
    if rid <> ? then 
    do:
      find first buf_code no-lock where
                 recid(buf_code) = rid no-error .
      if not avail buf_code then return error.
      /* проверка: Сезон ДТ может быть привязан только к 1-му ДТ на этом объекте */
      run gdsoattr-gds-code in this-procedure
        ("dt-seasons", buf_code.code, p-obj-type, p-obj-code, output gdsCode).
      if gdsCode <> 0 and gdsCode <> p-gds-code then
      do:
        find first buf_goods where
                   buf_goods.gds-code = gdsCode 
             no-lock no-error.
        message "Атрибут ~"Сезон ДТ~" может быть настроен только для одного дизельного топлива для одного объекта.~n"
                "Для товара " if available buf_goods then substitute("<&1 &2 &3>",buf_goods.gds-code, buf_goods.artic, buf_goods.gds-name) else ""
                "~nуже настроен атрибут ~"Сезон ДТ~" в значении " buf_code.code ".~n"
                "В установке атрибута «Сезон ДТ» отказано." view-as alert-box.
        undo, return error.
      end.
      assign
        p-value = buf_code.code
        p-setted = yes
      .
    end.
    else 
    do:
      if error-status:error then 
      do:
        message 
          return-value skip
          "В установке атрибута «Сезон ДТ» отказано." view-as alert-box
        .
      end.
      p-setted = no.
    end.
  end.

end procedure. /* gds-obj-dt-seasons */

/* ################## */
/* атрибуты внешних систем */

/* Необходимость формирования нового пакета(ов) для ВС */
&scop type-attr-need-gen-new-xpack {&type-log}
&scop format-attr-need-gen-new-xpack "+/-"
&scop label-attr-need-gen-new-xpack "Необходимость формирования нового пакета(ов) для ВС"
&scop tooltip-attr-need-gen-new-xpack "Необходимо ли формировать новый пакет(ы) для внешней системы"
&scop user-can-edit-attr-need-gen-new-xpack false
&scop output-display-attr-need-gen-new-xpack true
&scop other-attr-need-gen-new-xpack '':u
&scop news-attr-need-gen-new-xpack no
&scop manual-edit-attr-need-gen-new-xpack 0
&scop batch-edit-attr-need-gen-new-xpack 0

&scop type-attr-esys-ftp-ip {&type-char}
&scop format-attr-esys-ftp-ip "X(256)"
&scop label-attr-esys-ftp-ip "FTP"
&scop tooltip-attr-esys-ftp-ip "FTP (адрес)"
&scop user-can-edit-attr-esys-ftp-ip true
&scop output-display-attr-esys-ftp-ip false
&scop other-attr-esys-ftp-ip '':u
&scop news-attr-esys-ftp-ip yes
&scop manual-edit-attr-esys-ftp-ip 0
&scop batch-edit-attr-esys-ftp-ip 0

&scop type-attr-esys-ftp-login {&type-char}
&scop format-attr-esys-ftp-login "X(256)"
&scop label-attr-esys-ftp-login "Login"
&scop tooltip-attr-esys-ftp-login "Login FTP"
&scop user-can-edit-attr-esys-ftp-login true
&scop output-display-attr-esys-ftp-login false
&scop other-attr-esys-ftp-login '':u
&scop news-attr-esys-ftp-login yes
&scop manual-edit-attr-esys-ftp-login 0
&scop batch-edit-attr-esys-ftp-login 0

&scop type-attr-esys-ftp-password {&type-char}
&scop format-attr-esys-ftp-password "X(256)"
&scop label-attr-esys-ftp-password "Password"
&scop tooltip-attr-esys-ftp-password "Password FTP"
&scop user-can-edit-attr-esys-ftp-password true
&scop output-display-attr-esys-ftp-password false
&scop other-attr-esys-ftp-password '':u
&scop news-attr-esys-ftp-password yes
&scop manual-edit-attr-esys-ftp-password 0
&scop batch-edit-attr-esys-ftp-password 0

&scop type-attr-esys-ftp-path {&type-char}
&scop format-attr-esys-ftp-path "X(256)"
&scop label-attr-esys-ftp-path "Путь"
&scop tooltip-attr-esys-ftp-path "Путь (от HOME-директории)"
&scop user-can-edit-attr-esys-ftp-path true
&scop output-display-attr-esys-ftp-path false
&scop other-attr-esys-ftp-path '':u
&scop news-attr-esys-ftp-path yes
&scop manual-edit-attr-esys-ftp-path 0
&scop batch-edit-attr-esys-ftp-path 0

&scop type-attr-esys-ftp-path-in {&type-char}
&scop format-attr-esys-ftp-path-in "X(256)"
&scop label-attr-esys-ftp-path-in "Вход"
&scop tooltip-attr-esys-ftp-path-in "Папка Входящие"
&scop user-can-edit-attr-esys-ftp-path-in true
&scop output-display-attr-esys-ftp-path-in false
&scop other-attr-esys-ftp-path-in '':u
&scop news-attr-esys-ftp-path-in yes
&scop manual-edit-attr-esys-ftp-path-in 0
&scop batch-edit-attr-esys-ftp-path-in 0

&scop type-attr-esys-ftp-path-out {&type-char}
&scop format-attr-esys-ftp-path-out "X(256)"
&scop label-attr-esys-ftp-path-out "Исход"
&scop tooltip-attr-esys-ftp-path-out "Папка исходящие"
&scop user-can-edit-attr-esys-ftp-path-out true
&scop output-display-attr-esys-ftp-path-out false
&scop other-attr-esys-ftp-path-out '':u
&scop news-attr-esys-ftp-path-out yes
&scop manual-edit-attr-esys-ftp-path-out 0
&scop batch-edit-attr-esys-ftp-path-out 0

&scop           type-attr-esys-cert-sign {&type-log}
&scop         format-attr-esys-cert-sign "+/-"
&scop          label-attr-esys-cert-sign "Использовать цифровую подпись"
&scop        tooltip-attr-esys-cert-sign "Использовать цифровую подпись при обмене с внешней системой"
&scop  user-can-edit-attr-esys-cert-sign true
&scop output-display-attr-esys-cert-sign false
&scop          other-attr-esys-cert-sign '':u
&scop           news-attr-esys-cert-sign yes
&scop    manual-edit-attr-esys-cert-sign 0
&scop     batch-edit-attr-esys-cert-sign 0

&scop           type-attr-esys-cert-sign-subject {&type-char}
&scop         format-attr-esys-cert-sign-subject "X(256)"
&scop          label-attr-esys-cert-sign-subject "Владелец подписи (Субъект)"
&scop        tooltip-attr-esys-cert-sign-subject "Владелец подписи (Субъект)"
&scop  user-can-edit-attr-esys-cert-sign-subject true
&scop output-display-attr-esys-cert-sign-subject false
&scop          other-attr-esys-cert-sign-subject '':u
&scop           news-attr-esys-cert-sign-subject yes
&scop    manual-edit-attr-esys-cert-sign-subject 0
&scop     batch-edit-attr-esys-cert-sign-subject 0

&scop           type-attr-esys-cert-sign-issuer {&type-char}
&scop         format-attr-esys-cert-sign-issuer "X(256)"
&scop          label-attr-esys-cert-sign-issuer "Издатель подписи"
&scop        tooltip-attr-esys-cert-sign-issuer "Издатель подписи"
&scop  user-can-edit-attr-esys-cert-sign-issuer true
&scop output-display-attr-esys-cert-sign-issuer false
&scop          other-attr-esys-cert-sign-issuer '':u
&scop           news-attr-esys-cert-sign-issuer yes
&scop    manual-edit-attr-esys-cert-sign-issuer 0
&scop     batch-edit-attr-esys-cert-sign-issuer 0

&scop           type-attr-esys-cert-file-ext {&type-char}
&scop         format-attr-esys-cert-file-ext "X(6)"
&scop          label-attr-esys-cert-file-ext "Расширение имени файла"
&scop        tooltip-attr-esys-cert-file-ext "Расширение имени файла с цифровой подписью"
&scop  user-can-edit-attr-esys-cert-file-ext true
&scop output-display-attr-esys-cert-file-ext false
&scop          other-attr-esys-cert-file-ext '':u
&scop           news-attr-esys-cert-file-ext yes
&scop    manual-edit-attr-esys-cert-file-ext 0
&scop     batch-edit-attr-esys-cert-file-ext 0

&scop           type-attr-esys-cert-repository {&type-int}
&scop         format-attr-esys-cert-repository ">>9"
&scop          label-attr-esys-cert-repository "Хранилище сертификатов"
&scop        tooltip-attr-esys-cert-repository "Расположение хранилища сертификатов"
&scop  user-can-edit-attr-esys-cert-repository true
&scop output-display-attr-esys-cert-repository false
&scop          other-attr-esys-cert-repository '':u
&scop           news-attr-esys-cert-repository yes
&scop    manual-edit-attr-esys-cert-repository 0
&scop     batch-edit-attr-esys-cert-repository 0

&scop type-attr-esys-AuthToken {&type-char}
&scop format-attr-esys-AuthToken "X(16000)"
&scop label-attr-esys-AuthToken "Токен авторизации"
&scop tooltip-attr-esys-AuthToken "Токен авторизации"
&scop user-can-edit-attr-esys-AuthToken false
&scop output-display-attr-esys-AuthToken false
&scop other-attr-esys-AuthToken '':u
&scop news-attr-esys-AuthToken false
&scop manual-edit-attr-esys-AuthToken 0
&scop batch-edit-attr-esys-AuthToken 0

&scop type-attr-esys-AuthTokenDT {&type-char}
&scop format-attr-esys-AuthTokenDT "X(256)"
&scop label-attr-esys-AuthTokenDT "Дата и время запроса токена авторизации"
&scop tooltip-attr-esys-AuthTokenDT "Дата и время запроса токена авторизации"
&scop user-can-edit-attr-esys-AuthTokenDT false
&scop output-display-attr-esys-AuthTokenDT false
&scop other-attr-esys-AuthTokenDT '':u
&scop news-attr-esys-AuthTokenDT false
&scop manual-edit-attr-esys-AuthTokenDT 0
&scop batch-edit-attr-esys-AuthTokenDT 0

&scop type-attr-esys-proxy-ssl {&type-log}
&scop format-attr-esys-proxy-ssl "+/-"
&scop label-attr-esys-proxy-ssl "SSL прокси"
&scop tooltip-attr-esys-proxy-ssl "SSL прокси"
&scop user-can-edit-attr-esys-proxy-ssl true
&scop output-display-attr-esys-proxy-ssl false
&scop other-attr-esys-proxy-ssl '':u
&scop news-attr-esys-proxy-ssl false
&scop manual-edit-attr-esys-proxy-ssl 0
&scop batch-edit-attr-esys-proxy-ssl 0

&scop type-attr-esys-server-addr {&type-char}
&scop format-attr-esys-server-addr "X(256)"
&scop label-attr-esys-server-addr "Адрес сервера МОТП или Диадок"
&scop tooltip-attr-esys-server-addr "Адрес сервера МОТП или Диадок"
&scop user-can-edit-attr-esys-server-addr true
&scop output-display-attr-esys-server-addr false
&scop other-attr-esys-server-addr '':u
&scop news-attr-esys-server-addr false
&scop manual-edit-attr-esys-server-addr 0
&scop batch-edit-attr-esys-server-addr 0

&scop type-attr-esys-proxy-addr {&type-char}
&scop format-attr-esys-proxy-addr "X(256)"
&scop label-attr-esys-proxy-addr "Адрес прокси"
&scop tooltip-attr-esys-proxy-addr "Адрес прокси"
&scop user-can-edit-attr-esys-proxy-addr true
&scop output-display-attr-esys-proxy-addr false
&scop other-attr-esys-proxy-addr '':u
&scop news-attr-esys-proxy-addr false
&scop manual-edit-attr-esys-proxy-addr 0
&scop batch-edit-attr-esys-proxy-addr 0

&scop type-attr-esys-proxy-login {&type-char}
&scop format-attr-esys-proxy-login "X(256)"
&scop label-attr-esys-proxy-login "Логин прокси"
&scop tooltip-attr-esys-proxy-login "Логин прокси"
&scop user-can-edit-attr-esys-proxy-login true
&scop output-display-attr-esys-proxy-login false
&scop other-attr-esys-proxy-login '':u
&scop news-attr-esys-proxy-login false
&scop manual-edit-attr-esys-proxy-login 0
&scop batch-edit-attr-esys-proxy-login 0

&scop type-attr-esys-proxy-pswd {&type-char}
&scop format-attr-esys-proxy-pswd "X(256)"
&scop label-attr-esys-proxy-pswd "Пароль прокси"
&scop tooltip-attr-esys-proxy-pswd "Пароль прокси"
&scop user-can-edit-attr-esys-proxy-pswd true
&scop output-display-attr-esys-proxy-pswd false
&scop other-attr-esys-proxy-pswd '':u
&scop news-attr-esys-proxy-pswd yes
&scop manual-edit-attr-esys-proxy-pswd 0
&scop batch-edit-attr-esys-proxy-pswd 0

&scop type-attr-esys-host-code {&type-int}
&scop format-attr-esys-host-code ">>>>>>>>>9"
&scop label-attr-esys-host-code "Код фирмы"
&scop tooltip-attr-esys-host-code "Код фирмы"
&scop user-can-edit-attr-esys-host-code true
&scop output-display-attr-esys-host-code false
&scop other-attr-esys-host-code '':u
&scop news-attr-esys-host-code false
&scop manual-edit-attr-esys-host-code 0
&scop batch-edit-attr-esys-host-code 0

&scop type-attr-esys-obj {&type-char}
&scop format-attr-esys-obj "X(15)"
&scop label-attr-esys-obj "Объект"
&scop tooltip-attr-esys-obj "Объект"
&scop user-can-edit-attr-esys-obj true
&scop output-display-attr-esys-obj false
&scop other-attr-esys-obj '':u
&scop news-attr-esys-obj false
&scop manual-edit-attr-esys-obj 0
&scop batch-edit-attr-esys-obj 0

&scop type-attr-esys-user-id {&type-char}
&scop format-attr-esys-user-id "X(256)"
&scop label-attr-esys-user-id "Пользователь"
&scop tooltip-attr-esys-user-id "Пользователь"
&scop user-can-edit-attr-esys-user-id true
&scop output-display-attr-esys-user-id false
&scop other-attr-esys-user-id '':u
&scop news-attr-esys-user-id false
&scop manual-edit-attr-esys-user-id 0
&scop batch-edit-attr-esys-user-id 0

&scop type-attr-esys-AuthToken-send {&type-char}
&scop format-attr-esys-AuthToken-send "X(16000)"
&scop label-attr-esys-AuthToken-send "Просроченный токен авторизации"
&scop tooltip-attr-esys-AuthToken-send "Просроченный токен авторизации"
&scop user-can-edit-attr-esys-AuthToken-send false
&scop output-display-attr-esys-AuthToken-send false
&scop other-attr-esys-AuthToken-send '':u
&scop news-attr-esys-AuthToken-send false
&scop manual-edit-attr-esys-AuthToken-send 0
&scop batch-edit-attr-esys-AuthToken-send 0

&scop type-attr-esys-mail-list {&type-char}
&scop format-attr-esys-mail-list "X(1000)"
&scop label-attr-esys-mail-list "Список адресов эл. почты"
&scop tooltip-attr-esys-mail-list "Список адресов эл. почты для отправки уведомлений. Указывать через запятую."
&scop user-can-edit-attr-esys-mail-list true
&scop output-display-attr-esys-mail-list false
&scop other-attr-esys-mail-list '':u
&scop news-attr-esys-mail-list false
&scop manual-edit-attr-esys-mail-list 0
&scop batch-edit-attr-esys-mail-list 0

&scop type-attr-esys-diadoc-user {&type-char}
&scop format-attr-esys-diadoc-user "X(256)"
&scop label-attr-esys-diadoc-user "Пользователь Диадок"
&scop tooltip-attr-esys-diadoc-user "Пользователь Диадок"
&scop user-can-edit-attr-esys-diadoc-user true
&scop output-display-attr-esys-diadoc-user false
&scop other-attr-esys-diadoc-user '':u
&scop news-attr-esys-diadoc-user false
&scop manual-edit-attr-esys-diadoc-user 0
&scop batch-edit-attr-esys-diadoc-user 0

&scop type-attr-esys-diadoc-pwd {&type-char}
&scop format-attr-esys-diadoc-pwd "X(256)"
&scop label-attr-esys-diadoc-pwd "Пароль пользователя Диадок"
&scop tooltip-attr-esys-diadoc-pwd "Пароль пользователя Диадок"
&scop user-can-edit-attr-esys-diadoc-pwd true
&scop output-display-attr-esys-diadoc-pwd false
&scop other-attr-esys-diadoc-pwd '':u
&scop news-attr-esys-diadoc-pwd false
&scop manual-edit-attr-esys-diadoc-pwd 0
&scop batch-edit-attr-esys-diadoc-pwd 0

&scop type-attr-esys-diadoc-key {&type-char}
&scop format-attr-esys-diadoc-key "X(256)"
&scop label-attr-esys-diadoc-key "Ключ разработчика Диадок"
&scop tooltip-attr-esys-diadoc-key "Ключ разработчика Диадок"
&scop user-can-edit-attr-esys-diadoc-key true
&scop output-display-attr-esys-diadoc-key false
&scop other-attr-esys-diadoc-key '':u
&scop news-attr-esys-diadoc-key false
&scop manual-edit-attr-esys-diadoc-key 0
&scop batch-edit-attr-esys-diadoc-key 0

&scop type-attr-esys-diadoc-lastload {&type-date}
&scop format-attr-esys-diadoc-lastload "99/99/9999"
&scop label-attr-esys-diadoc-lastload "Дата последнего загруженого документа Диадок"
&scop tooltip-attr-esys-diadoc-lastload "Дата последнего загруженого документа Диадок"
&scop user-can-edit-attr-esys-diadoc-lastload true
&scop output-display-attr-esys-diadoc-lastload false
&scop other-attr-esys-diadoc-lastload '':u
&scop news-attr-esys-diadoc-lastload false
&scop manual-edit-attr-esys-diadoc-lastload 0
&scop batch-edit-attr-esys-diadoc-lastload 0

&scop type-attr-esys-diadoc-ssl {&type-log}
&scop format-attr-esys-diadoc-ssl "yes/no"
&scop label-attr-esys-diadoc-ssl "Отключение проверки шифрования Диадок"
&scop tooltip-attr-esys-diadoc-ssl "Отключение проверки шифрования Диадок"
&scop user-can-edit-attr-esys-diadoc-ssl true
&scop output-display-attr-esys-diadoc-ssl false
&scop other-attr-esys-diadoc-ssl '':u
&scop news-attr-esys-diadoc-ssl false
&scop manual-edit-attr-esys-diadoc-ssl 0
&scop batch-edit-attr-esys-diadoc-ssl 0


/* сюда добавлять новые параметры атрибутов ВС */

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure ext-system-attr-code :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-need-gen-new-xpack
      {&attr-temp-full-code}
      &scop attr-code attr-esys-ftp-ip
      {&attr-temp-full-code}
      &scop attr-code attr-esys-ftp-login
      {&attr-temp-full-code}
      &scop attr-code attr-esys-ftp-password
      {&attr-temp-full-code}
      &scop attr-code attr-esys-ftp-path
      {&attr-temp-full-code}
      &scop attr-code attr-esys-ftp-path-in
      {&attr-temp-full-code}
      &scop attr-code attr-esys-ftp-path-out
      {&attr-temp-full-code}
      &scop attr-code attr-esys-cert-sign
      {&attr-temp-full-code}
      &scop attr-code attr-esys-cert-sign-subject
      {&attr-temp-full-code}
      &scop attr-code attr-esys-cert-sign-issuer
      {&attr-temp-full-code}
      &scop attr-code attr-esys-cert-file-ext
      {&attr-temp-full-code}
      &scop attr-code attr-esys-cert-repository
      {&attr-temp-full-code}
      &scop attr-code attr-esys-AuthToken
      {&attr-temp-full-code}
      &scop attr-code attr-esys-AuthTokenDT
      {&attr-temp-full-code}
      &scop attr-code attr-esys-host-code
      {&attr-temp-full-code}
      &scop attr-code attr-esys-obj
      {&attr-temp-full-code}
      &scop attr-code attr-esys-user-id
      {&attr-temp-full-code}
      &scop attr-code attr-esys-server-addr
      {&attr-temp-full-code}
      &scop attr-code attr-esys-proxy-addr
      {&attr-temp-full-code}
      &scop attr-code attr-esys-proxy-login
      {&attr-temp-full-code}
      &scop attr-code attr-esys-proxy-pswd
      {&attr-temp-full-code}
      &scop attr-code attr-esys-proxy-ssl
      {&attr-temp-full-code}
      &scop attr-code attr-esys-AuthToken-send
      {&attr-temp-full-code}
      &scop attr-code attr-esys-mail-list
      {&attr-temp-full-code}
      &scop attr-code attr-esys-diadoc-user
      {&attr-temp-full-code}
      &scop attr-code attr-esys-diadoc-pwd 
      {&attr-temp-full-code}
      &scop attr-code attr-esys-diadoc-key
      {&attr-temp-full-code}
      &scop attr-code attr-esys-diadoc-lastload
      {&attr-temp-full-code}
      &scop attr-code attr-esys-diadoc-ssl
      {&attr-temp-full-code}


      /* сюда добавлять новые параметры атрибутов ВС */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure ext-system-attr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-need-gen-new-xpack
      {&attr-temp-code}
      &scop attr-code attr-esys-ftp-ip
      {&attr-temp-code}
      &scop attr-code attr-esys-ftp-login
      {&attr-temp-code}
      &scop attr-code attr-esys-ftp-password
      {&attr-temp-code}
      &scop attr-code attr-esys-ftp-path
      {&attr-temp-code}
      &scop attr-code attr-esys-ftp-path-in
      {&attr-temp-code}
      &scop attr-code attr-esys-ftp-path-out
      {&attr-temp-code}
      &scop attr-code attr-esys-cert-sign
      {&attr-temp-code}
      &scop attr-code attr-esys-cert-sign-subject
      {&attr-temp-code}
      &scop attr-code attr-esys-cert-sign-issuer
      {&attr-temp-code}
      &scop attr-code attr-esys-cert-file-ext
      {&attr-temp-code}
      &scop attr-code attr-esys-cert-repository
      {&attr-temp-code}
      &scop attr-code attr-esys-AuthToken
      {&attr-temp-code}
      &scop attr-code attr-esys-AuthTokenDT
      {&attr-temp-code}
      &scop attr-code attr-esys-host-code
      {&attr-temp-code}
      &scop attr-code attr-esys-obj
      {&attr-temp-code}
      &scop attr-code attr-esys-user-id
      {&attr-temp-code}
      &scop attr-code attr-esys-server-addr
      {&attr-temp-code}
      &scop attr-code attr-esys-proxy-addr
      {&attr-temp-code}
      &scop attr-code attr-esys-proxy-login
      {&attr-temp-code}
      &scop attr-code attr-esys-proxy-pswd
      {&attr-temp-code}
      &scop attr-code attr-esys-proxy-ssl
      {&attr-temp-code}
      &scop attr-code attr-esys-AuthToken-send
      {&attr-temp-code}
      &scop attr-code attr-esys-mail-list
      {&attr-temp-code}
      &scop attr-code attr-esys-diadoc-user
      {&attr-temp-code}
      &scop attr-code attr-esys-diadoc-pwd
      {&attr-temp-code}
      &scop attr-code attr-esys-diadoc-key
      {&attr-temp-code}
      &scop attr-code attr-esys-diadoc-lastload
      {&attr-temp-code}
      &scop attr-code attr-esys-diadoc-ssl
      {&attr-temp-code}
      

      /* сюда добавлять новые параметры атрибутов ВС */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .

  do
  on error undo, return error
  :
    define buffer buf_ext-system-attr for ub.ext-system-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ext-system-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ext-system-attr no-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error .
    if avail buf_ext-system-attr then do:
      assign
        p-value =  buf_ext-system-attr.esya-attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure ext-system-attr-write :

  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .

  do
  on error undo, return error
  :
    define buffer buf_ext-system-attr for ub.ext-system-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ext-system-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ext-system-attr exclusive-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error .
    if not available buf_ext-system-attr then do:
      create buf_ext-system-attr .
      assign
        buf_ext-system-attr.esys-id   = p-esys-id
        buf_ext-system-attr.db-num    = p-db-num
        buf_ext-system-attr.esya-attr-code = p-code
      .
    end.
    assign
      buf_ext-system-attr.esya-attr-value = p-value
    .
  end.

end procedure.


procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    define buffer buf_ext-system-attr for ub.ext-system-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ext-system-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ext-system-attr no-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error .
    if  available buf_ext-system-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure ext-system-attr-delete :
  define input parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    define buffer buf_ext-system-attr for ub.ext-system-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ext-system-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ext-system-attr exclusive-lock
      where buf_ext-system-attr.esys-id   = p-esys-id
        and buf_ext-system-attr.db-num    = p-db-num
        and buf_ext-system-attr.esya-attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ext-system-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ext-system-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure ext-system-attr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-need-gen-new-xpack
      {&attr-news-code}
      &scop attr-code attr-esys-ftp-ip
      {&attr-news-code}
      &scop attr-code attr-esys-ftp-login
      {&attr-news-code}
      &scop attr-code attr-esys-ftp-password
      {&attr-news-code}
      &scop attr-code attr-esys-ftp-path
      {&attr-news-code}
      &scop attr-code attr-esys-ftp-path-in
      {&attr-news-code}
      &scop attr-code attr-esys-ftp-path-out
      {&attr-news-code}
      &scop attr-code attr-esys-cert-sign
      {&attr-news-code}
      &scop attr-code attr-esys-cert-sign-subject
      {&attr-news-code}
      &scop attr-code attr-esys-cert-sign-issuer
      {&attr-news-code}
      &scop attr-code attr-esys-cert-file-ext
      {&attr-news-code}
      &scop attr-code attr-esys-cert-repository
      {&attr-news-code}
      &scop attr-code attr-ver-code
      {&attr-news-code}
      &scop attr-code attr-esys-AuthToken
      {&attr-news-code}
      &scop attr-code attr-esys-AuthTokenDT
      {&attr-news-code}
      &scop attr-code attr-esys-host-code
      {&attr-news-code}
      &scop attr-code attr-esys-obj
      {&attr-news-code}
      &scop attr-code attr-esys-user-id
      {&attr-news-code}
      &scop attr-code attr-esys-server-addr
      {&attr-news-code}
      &scop attr-code attr-esys-proxy-addr
      {&attr-news-code}
      &scop attr-code attr-esys-proxy-login
      {&attr-news-code}
      &scop attr-code attr-esys-proxy-pswd
      {&attr-news-code}
      &scop attr-code attr-esys-proxy-ssl
      {&attr-news-code}
      &scop attr-code attr-esys-AuthToken-send
      {&attr-news-code}
      &scop attr-code attr-esys-mail-list
      {&attr-news-code}
      &scop attr-code attr-esys-diadoc-user
      {&attr-news-code}
      &scop attr-code attr-esys-diadoc-pwd
      {&attr-news-code}
      &scop attr-code attr-esys-diadoc-key
      {&attr-news-code}
      &scop attr-code attr-esys-diadoc-lastload
      {&attr-news-code}
      &scop attr-code attr-esys-diadoc-ssl
      {&attr-news-code}
      &scop attr-code attr-reg-code
      {&attr-news-code}
      &scop attr-code attr-last-nws-sync
      {&attr-news-code}
      

      /* сюда добавлять новые параметры атрибутов ВС */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.


/*секция pop-up меню при ручном редактировании */
procedure ext-system-attr-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибутов ВС*/
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure ext-system-attr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибутов ВС */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code ).
      end.
    end.
  end.
end procedure.

/* ################## */
/* атрибуты принятых пакетов СПН */
/* ни в коем случае не должны сами ходить по новостям!!! */

 /* Дата начала разбора пакета */
&scop type-attr-beg-imp-date {&type-date}
&scop format-attr-beg-imp-date "99.99.9999"
&scop label-attr-beg-imp-date "Дата начала приема пакета"
&scop tooltip-attr-beg-imp-date "Дата начала приема пакета"
&scop user-can-edit-attr-beg-imp-date false
&scop output-display-attr-beg-imp-date true
&scop other-attr-beg-imp-date '':u
&scop news-attr-beg-imp-date no /* ни в коем случае не должен сам ходить по новостям!!! */
&scop manual-edit-attr-beg-imp-date 0
&scop batch-edit-attr-beg-imp-date 0

/* Время начала разбора пакета */
&scop type-attr-beg-imp-time {&type-int}
&scop format-attr-beg-imp-time ">>>>>>>>>9"
&scop label-attr-beg-imp-time "Время начала разбора пакета"
&scop tooltip-attr-beg-imp-time "Время начала разбора пакета"
&scop user-can-edit-attr-beg-imp-time false
&scop output-display-attr-beg-imp-time true
&scop other-attr-beg-imp-time '':u
&scop news-attr-beg-imp-time no /* ни в коем случае не должен сам ходить по новостям!!! */
&scop manual-edit-attr-beg-imp-time 0
&scop batch-edit-attr-beg-imp-time 0

/* сюда добавлять новые параметры атрибутов принятых пакетов */

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure pck-attr-code :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-beg-imp-date
      {&attr-temp-full-code}
      &scop attr-code attr-beg-imp-time
      {&attr-temp-full-code}

      /* сюда добавлять новые параметры атрибутов принятых пакетов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ) .
      end.
    end.
  end.
end procedure.

procedure pck-attr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-beg-imp-date
      {&attr-temp-code}
      &scop attr-code attr-beg-imp-time
      {&attr-temp-code}

      /* сюда добавлять новые параметры атрибутов принятых пакетов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ) .
      end.
    end.
  end.

end procedure.


procedure pck-attr-value :

  define input  parameter p-tbl-pck   as   character                   no-undo .
  define input  parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  define output parameter p-type      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run pck-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr no-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error .
      if available buf_pck-rcvd-attr then do:
        assign
          p-value = buf_pck-rcvd-attr.attr-value
        .
      end.
      else do:
        assign
          p-value = if p-type = {&type-log} then "no":U else ""
        .
      end.
    end.
    else do:
      find first buf_pck-sent-attr no-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error .
      if available buf_pck-sent-attr then do:
        assign
          p-value = buf_pck-sent-attr.attr-value
        .
      end.
      else do:
        assign
          p-value = if p-type = {&type-log} then "no":U else ""
        .
      end.
    end.
  end.

end procedure.


procedure pck-attr-write :

  define input parameter p-tbl-pck   as   character                   no-undo .
  define input parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define input parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .

  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run pck-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.


    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr exclusive-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error .
      if not available buf_pck-rcvd-attr then do:
        create buf_pck-rcvd-attr .
        assign
          buf_pck-rcvd-attr.db-num    = p-db-num
          buf_pck-rcvd-attr.pack-num  = p-pack-num
          buf_pck-rcvd-attr.attr-code = p-code
        .
      end.
      assign
        buf_pck-rcvd-attr.attr-value = p-value
      .
    end.
    else do:
      find first buf_pck-sent-attr exclusive-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error .
      if not available buf_pck-sent-attr then do:
        create buf_pck-sent-attr .
        assign
          buf_pck-sent-attr.db-num    = p-db-num
          buf_pck-sent-attr.pack-num  = p-pack-num
          buf_pck-sent-attr.attr-code = p-code
        .
      end.
      assign
        buf_pck-sent-attr.attr-value = p-value
      .
    end.
  end.

end procedure.


procedure pck-attr-exist :

  define input  parameter p-tbl-pck   as   character                   no-undo .
  define input  parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run pck-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr no-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error .
      if available buf_pck-rcvd-attr then do:
        assign
          p-exist = yes
        .
      end.
    end.
    else do:
      find first buf_pck-sent-attr no-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error .
      if available buf_pck-sent-attr then do:
        assign
          p-exist = yes
        .
      end.
    end.
  end.

end procedure.

procedure pck-attr-delete :

  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    define buffer buf_pck-sent-attr for ub.pck-sent-attr .
    define buffer buf_pck-rcvd-attr for ub.pck-rcvd-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run pck-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    if p-tbl-pck = "pck-rcvd":U then do:
      find first buf_pck-rcvd-attr exclusive-lock
        where buf_pck-rcvd-attr.db-num    = p-db-num
          and buf_pck-rcvd-attr.pack-num  = p-pack-num
          and buf_pck-rcvd-attr.attr-code = p-code
        no-error NO-WAIT.
      if not available buf_pck-rcvd-attr then do:
        p-deleted = no.
      end.
      else do:
        delete buf_pck-rcvd-attr.
        p-deleted = yes.
      end.
    end.
    else do:
      find first buf_pck-sent-attr exclusive-lock
        where buf_pck-sent-attr.db-num    = p-db-num
          and buf_pck-sent-attr.pack-num  = p-pack-num
          and buf_pck-sent-attr.attr-code = p-code
        no-error NO-WAIT.
      if not available buf_pck-sent-attr then do:
        p-deleted = no.
      end.
      else do:
        delete buf_pck-sent-attr.
        p-deleted = yes.
      end.
    end.
  end.

end procedure.


procedure pck-attr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-beg-imp-date
      {&attr-news-code}
      &scop attr-code attr-beg-imp-time
      {&attr-news-code}

      /* сюда добавлять новые параметры атрибутов принятых пакетов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ) .
      end.
    end.
  end.
end procedure.


/*секция pop-up меню при ручном редактировании */
procedure pck-attr-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-beg-imp-date
      {&attr-manual-edit-code}
      &scop attr-code attr-beg-imp-time
      {&attr-manual-edit-code}

      /* сюда добавлять новые параметры атрибутов принятых пакетов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure pck-attr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code attr-beg-imp-date
      {&attr-batch-edit-code}
      &scop attr-code attr-beg-imp-time
      {&attr-batch-edit-code}

      /* сюда добавлять новые параметры атрибутов принятых пакетов */
      otherwise do:
        undo, return error substitute("неизвестный атрибут принятого пакета &1", p-code ).
      end.
    end.
  end.
end procedure.

/* ################## */
/* атрибуты группы товаров на объекте  */

/* Запрет на корректировку автоматически рассчитанного заказа ОП */
&scop type-ggoattr-NotCorrOP {&type-log}
&scop format-ggoattr-NotCorrOP "+/-"
&scop label-ggoattr-NotCorrOP "Запрет на корректировку автоматически рассчитанного заказа ОП"
&scop tooltip-ggoattr-NotCorrOP "Запрет на корректировку авт.рассчит.заказа ОП"
&scop user-can-edit-ggoattr-NotCorrOP  true
&scop output-display-ggoattr-NotCorrOP true
&scop other-ggoattr-NotCorrOP '':u
&scop news-ggoattr-NotCorrOP true
&scop manual-edit-ggoattr-NotCorrOP 0
&scop batch-edit-ggoattr-NotCorrOP 0

/* Правила определения минимальной цены алкоголя*/
&scop type-ggoattr-alc-min-price {&type-char}
&scop format-ggoattr-alc-min-price "X(256)"
&scop label-ggoattr-alc-min-price "Правила определения минимальной цены алкоголя"
&scop tooltip-ggoattr-alc-min-price "Правила определения минимальной цены алкоголя"
&scop user-can-edit-ggoattr-alc-min-price  true
&scop output-display-ggoattr-alc-min-price true
&scop other-ggoattr-alc-min-price '':u
&scop news-ggoattr-alc-min-price true
&scop manual-edit-ggoattr-alc-min-price 0
&scop batch-edit-ggoattr-alc-min-price 0

/* Правила определения наценки к цене внутреннего прихода партии*/
&scop type-ggoattr-marg-pr-paraf {&type-char}
&scop format-ggoattr-marg-pr-paraf "X(256)"
&scop label-ggoattr-marg-pr-paraf "Правила определения наценки к цене внутреннего прихода партии"
&scop tooltip-ggoattr-marg-pr-paraf "Правила определения наценки к цене внутреннего прихода партии"
&scop user-can-edit-ggoattr-marg-pr-paraf  true
&scop output-display-ggoattr-marg-pr-paraf true
&scop other-ggoattr-marg-pr-paraf '':u
&scop news-ggoattr-marg-pr-paraf true
&scop manual-edit-ggoattr-marg-pr-paraf 0
&scop batch-edit-ggoattr-marg-pr-paraf 0

/* Правила определения границ пороговой наценки*/
&scop type-ggoattr-level-dis {&type-char}
&scop format-ggoattr-level-dis "X(256)"
&scop label-ggoattr-level-dis "Правила определения границ пороговой наценки"
&scop tooltip-ggoattr-level-dis "Правила определения границ пороговой наценки"
&scop user-can-edit-ggoattr-level-dis  true
&scop output-display-ggoattr-level-dis true
&scop other-ggoattr-level-dis '':u
&scop news-ggoattr-level-dis true
&scop manual-edit-ggoattr-level-dis 0
&scop batch-edit-ggoattr-level-dis 0

/* Не учитывать в автоматической отчетности */
&scop type-ggoattr-no-inc-auto-rep {&type-char}
&scop format-ggoattr-no-inc-auto-rep "X(256)"
&scop label-ggoattr-no-inc-auto-rep "Не учитывать в автоматической отчетности"
&scop tooltip-ggoattr-no-inc-auto-rep "Не учитывать в автоматической отчетности"
&scop user-can-edit-ggoattr-no-inc-auto-rep  false
&scop output-display-ggoattr-no-inc-auto-rep true
&scop other-ggoattr-no-inc-auto-rep '':u
&scop news-ggoattr-no-inc-auto-rep true
&scop manual-edit-ggoattr-no-inc-auto-rep 0
&scop batch-edit-ggoattr-no-inc-auto-rep 0

/* Запрет продажи через кассу */
&scop type-ggoattr-ban-sales-via-cd {&type-char}
&scop format-ggoattr-ban-sales-via-cd "X(256)"
&scop label-ggoattr-ban-sales-via-cd "Запрет продажи через кассу"
&scop tooltip-ggoattr-ban-sales-via-cd "Запрет продажи через кассу"
&scop user-can-edit-ggoattr-ban-sales-via-cd  false
&scop output-display-ggoattr-ban-sales-via-cd true
&scop other-ggoattr-ban-sales-via-cd '':u
&scop news-ggoattr-ban-sales-via-cd true
&scop manual-edit-ggoattr-ban-sales-via-cd 0
&scop batch-edit-ggoattr-ban-sales-via-cd 0

/* По умолчанию алкоголь */
&scop type-ggoattr-alchol-grp {&type-char}
&scop format-ggoattr-alchol-grp "X(256)"
&scop label-ggoattr-alchol-grp "По умолчанию алкоголь"
&scop tooltip-ggoattr-alchol-grp "По умолчанию алкоголь"
&scop user-can-edit-ggoattr-alchol-grp  false
&scop output-display-ggoattr-alchol-grp true
&scop other-ggoattr-alchol-grp '':u
&scop news-ggoattr-alchol-grp true
&scop manual-edit-ggoattr-alchol-grp 0
&scop batch-edit-ggoattr-alchol-grp 0

/* По умолчанию обязательная маркировка */
&scop type-ggoattr-mark-grp {&type-char}
&scop format-ggoattr-mark-grp "X(256)"
&scop label-ggoattr-mark-grp "По умолчанию обязательная маркировка"
&scop tooltip-ggoattr-mark-grp "По умолчанию обязательная маркировка"
&scop user-can-edit-ggoattr-mark-grp  false
&scop output-display-ggoattr-mark-grp true
&scop other-ggoattr-mark-grp '':u
&scop news-ggoattr-mark-grp true
&scop manual-edit-ggoattr-mark-grp 0
&scop batch-edit-ggoattr-mark-grp 0

/* Группа товаров на кассе */
&scop type-ggoattr-sum-grps {&type-int}
&scop format-ggoattr-sum-grps "999"
&scop label-ggoattr-sum-grps "Группа товаров на кассе"
&scop tooltip-ggoattr-sum-grps "Группа товаров на кассе"
&scop user-can-edit-ggoattr-sum-grps  false
&scop output-display-ggoattr-sum-grps true
&scop other-ggoattr-sum-grps '':u
&scop news-ggoattr-sum-grps true
&scop manual-edit-ggoattr-sum-grps 0
&scop batch-edit-ggoattr-sum-grps 0

/* По умолчанию тип маркировки */
&scop type-ggoattr-mark-type {&type-char}
&scop format-ggoattr-mark-type "X(256)"
&scop label-ggoattr-mark-type "Тип маркировки"
&scop tooltip-ggoattr-mark-type "Тип маркировки"
&scop user-can-edit-ggoattr-mark-type  false
&scop output-display-ggoattr-mark-type true
&scop other-ggoattr-mark-type '':u
&scop news-ggoattr-mark-type true
&scop manual-edit-ggoattr-mark-type 0
&scop batch-edit-ggoattr-mark-type 0

/* По умолчанию тип маркировки */
&scop type-ggoattr-emrc-type {&type-char}
&scop format-ggoattr-emrc-type "X(256)"
&scop label-ggoattr-emrc-type "Тип маркировки"
&scop tooltip-ggoattr-emrc-type "Тип маркировки"
&scop user-can-edit-ggoattr-emrc-type  false
&scop output-display-ggoattr-emrc-type true
&scop other-ggoattr-emrc-type '':u
&scop news-ggoattr-emrc-type true
&scop manual-edit-ggoattr-emrc-type 0
&scop batch-edit-ggoattr-emrc-type 0

/* сюда добавлять новые параметры атрибуты группы товаров на объекте */

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure ggoattr-code :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code ggoattr-NotCorrOP
      {&attr-temp-full-code}
      &scop attr-code ggoattr-alc-min-price
      {&attr-temp-full-code}
	  &scop attr-code ggoattr-marg-pr-paraf
      {&attr-temp-full-code}
      &scop attr-code ggoattr-level-dis
      {&attr-temp-full-code}
      &scop attr-code ggoattr-no-inc-auto-rep
      {&attr-temp-full-code}
      &scop attr-code ggoattr-ban-sales-via-cd
      {&attr-temp-full-code}
      &scop attr-code ggoattr-alchol-grp
      {&attr-temp-full-code}
      &scop attr-code ggoattr-mark-grp
      {&attr-temp-full-code}
      &scop attr-code ggoattr-sum-grps
      {&attr-temp-full-code}
      &scop attr-code ggoattr-mark-type
      {&attr-temp-full-code}      
      &scop attr-code ggoattr-emrc-type
      {&attr-temp-full-code}      
      /* сюда добавлять новые параметры атрибутов баз данных */
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure ggoattr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code ggoattr-NotCorrOP
      {&attr-temp-code}
      &scop attr-code ggoattr-alc-min-price
      {&attr-temp-code}
      &scop attr-code ggoattr-marg-pr-paraf
      {&attr-temp-code}
      &scop attr-code ggoattr-level-dis
      {&attr-temp-code}
      &scop attr-code ggoattr-no-inc-auto-rep
      {&attr-temp-code}
      &scop attr-code ggoattr-ban-sales-via-cd
      {&attr-temp-code}
      &scop attr-code ggoattr-alchol-grp
      {&attr-temp-code}
      &scop attr-code ggoattr-mark-grp
      {&attr-temp-code}
      &scop attr-code ggoattr-sum-grps
      {&attr-temp-code}
      &scop attr-code ggoattr-mark-type
      {&attr-temp-code}
      &scop attr-code ggoattr-emrc-type
      {&attr-temp-code}
      /* сюда добавлять новые параметры атрибуты группы товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure ggoattr-value :

  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code         like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value        like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type         as character no-undo .

  do
  on error undo, return error
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ggoattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code   = p-code
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        p-value =  buf_gds-grp-obj-attr.attr-value
      .
    end.
    else do:
      if p-obj-type <> "" then do: /* obj */
          find first buf_gds-grp-obj-attr no-lock
            where buf_gds-grp-obj-attr.node-code   = p-node-code
              and buf_gds-grp-obj-attr.host-code   = p-host-code
              and buf_gds-grp-obj-attr.obj-type    = ""
              and buf_gds-grp-obj-attr.obj-code    = 0
              and buf_gds-grp-obj-attr.attr-code   = p-code
            no-error .
          if available buf_gds-grp-obj-attr then do:
              assign
                p-value =  buf_gds-grp-obj-attr.attr-value
              .
          end.
          else do:
                find first buf_gds-grp-obj-attr no-lock
                  where buf_gds-grp-obj-attr.node-code   = p-node-code
                    and buf_gds-grp-obj-attr.host-code   = 0
                    and buf_gds-grp-obj-attr.obj-type    = ""
                    and buf_gds-grp-obj-attr.obj-code    = 0
                    and buf_gds-grp-obj-attr.attr-code   = p-code
                  no-error .
                if available buf_gds-grp-obj-attr then do:
                    assign
                      p-value =  buf_gds-grp-obj-attr.attr-value
                    .
                end.
                else do:
                   assign
                     p-value = if p-type = {&type-log} then "no":U else ""
                   .
                 end.
           end.
      end.
      if p-obj-type = "" and p-host-code <> 0 then do: /* firm */
          find first buf_gds-grp-obj-attr no-lock
            where buf_gds-grp-obj-attr.node-code   = p-node-code
              and buf_gds-grp-obj-attr.host-code   = 0
              and buf_gds-grp-obj-attr.obj-type    = ""
              and buf_gds-grp-obj-attr.obj-code    = 0
              and buf_gds-grp-obj-attr.attr-code   = p-code
            no-error .
          if available buf_gds-grp-obj-attr then do:
              assign
                p-value =  buf_gds-grp-obj-attr.attr-value
              .
          end.
          else do:
              assign
                p-value = if p-type = {&type-log} then "no":U else ""
              .
          end.
      end.
      if p-obj-type = "" and p-host-code = 0 then do: /* glob */
        assign
          p-value = if p-type = {&type-log} then "no":U else ""
        .
      end.
    end.
  end.

end procedure.


procedure ggoattr-write :

  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .

  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ggoattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.

    find first buf_gds-grp-obj-attr exclusive-lock
      where buf_gds-grp-obj-attr.node-code    = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code = p-code
      no-error .
    if not available buf_gds-grp-obj-attr then do:
      create buf_gds-grp-obj-attr .
      assign
        buf_gds-grp-obj-attr.host-code   = p-host-code
        buf_gds-grp-obj-attr.obj-type    = p-obj-type
        buf_gds-grp-obj-attr.obj-code    = p-obj-code
        buf_gds-grp-obj-attr.node-code    = p-node-code
        buf_gds-grp-obj-attr.attr-code = p-code
      .
    end.
    assign
      buf_gds-grp-obj-attr.attr-value = p-value
    .
  end.

end procedure.


procedure ggoattr-exist :

  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ggoattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code    = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code = p-code
      no-error .
    if  available buf_gds-grp-obj-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure ggoattr-delete :

  define input parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run ggoattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_gds-grp-obj-attr exclusive-lock
      where buf_gds-grp-obj-attr.node-code    = p-node-code
        and buf_gds-grp-obj-attr.host-code   = p-host-code
        and buf_gds-grp-obj-attr.obj-type    = p-obj-type
        and buf_gds-grp-obj-attr.obj-code    = p-obj-code
        and buf_gds-grp-obj-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_gds-grp-obj-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_gds-grp-obj-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure ggoattr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code ggoattr-NotCorrOP
      {&attr-news-code}
      &scop attr-code ggoattr-alc-min-price
      {&attr-news-code}
	  &scop attr-code ggoattr-marg-pr-paraf
      {&attr-news-code}
      &scop attr-code ggoattr-level-dis
      {&attr-news-code}
      &scop attr-code ggoattr-no-inc-auto-rep
      {&attr-news-code}
      &scop attr-code ggoattr-ban-sales-via-cd
      {&attr-news-code}
      &scop attr-code ggoattr-alchol-grp
      {&attr-news-code}
      &scop attr-code ggoattr-mark-grp
      {&attr-news-code}
      &scop attr-code ggoattr-sum-grps
      {&attr-news-code}
      &scop attr-code ggoattr-mark-type
      {&attr-news-code}
      &scop attr-code ggoattr-emrc-type
      {&attr-news-code}
      /* сюда добавлять новые параметры атрибуты группы товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code) .
      end.
    end.
  end.
end procedure.


/*секция pop-up меню при ручном редактировании */
procedure ggoattr-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибуты группы товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure ggoattr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибуты группы товаров на объекте */
      otherwise do:
        undo, return error substitute("неизвестный атрибут группы товаров на объекте &1", p-code ).
      end.
    end.
  end.
end procedure.

/* ################## */
/* атрибуты ассортиментных матриц  */

/* Указание на шаблон Номер и БД через {&delim-par} */
&scop type-assmatat-RootShablon  {&type-char}
&scop format-assmatat-RootShablon "X(40)"
&scop label-assmatat-RootShablon "Указание на шаблон"
&scop tooltip-assmatat-RootShablon "Шаблон к которому привязана АссМатрица"
&scop user-can-edit-assmatat-RootShablon  false
&scop output-display-assmatat-RootShablon false
&scop other-assmatat-RootShablon '':u
&scop news-assmatat-RootShablon true
&scop manual-edit-assmatat-RootShablon 0
&scop batch-edit-assmatat-RootShablon 0


/* сюда добавлять новые параметры атрибуты ассортиментной матрицы */

&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


procedure assmatat-code :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code assmatat-RootShablon
      {&attr-temp-full-code}
      &scop attr-code ggoattr-alchol-grp
      {&attr-temp-full-code}
      &scop attr-code ggoattr-mark-grp
      {&attr-temp-full-code}
      &scop attr-code ggoattr-sum-grps
      {&attr-temp-full-code}
      &scop attr-code ggoattr-mark-type
      {&attr-temp-full-code}
      &scop attr-code ggoattr-emrc-type
      {&attr-temp-full-code}
      /* сюда добавлять новые параметры атрибутов баз данных */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code) .
      end.
    end.
  end.
end procedure.

procedure assmatat-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code assmatat-RootShablon
      {&attr-temp-code}

      /* сюда добавлять новые параметры атрибуты ассортиментной матрицы */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure assmatat-value :

  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code         like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value        like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type         as character no-undo .

  do
  on error undo, return error
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run assmatat-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_assortment-matrix-attr no-lock
        where  buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num        = p-db-num
        and buf_assortment-matrix-attr.attr-code     = p-code
      no-error .
    if available buf_assortment-matrix-attr then do:
      assign
        p-value =  buf_assortment-matrix-attr.attr-value
      .
    end.
    else do:
        assign
          p-value = if p-type = {&type-log} then "no":U else ""
        .
      end.
 end.
end procedure.


procedure assmatat-write :

  define input parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .

  do
  on error undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1))
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run assmatat-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error SUBSTITUTE("&1, &2", return-value, Error-status:get-message(1)) .
    end.

    find first buf_assortment-matrix-attr exclusive-lock
      where
            buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num    = p-db-num
        and buf_assortment-matrix-attr.attr-code = p-code
      no-error .
    if not available buf_assortment-matrix-attr then do:
      create buf_assortment-matrix-attr .
      assign
        buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        buf_assortment-matrix-attr.db-num    = p-db-num
        buf_assortment-matrix-attr.attr-code = p-code
      .
    end.
    assign
      buf_assortment-matrix-attr.attr-value = p-value
    .
  end.

end procedure.


procedure assmatat-exist :

  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run assmatat-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_assortment-matrix-attr no-lock
      where
         buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num    = p-db-num
        and buf_assortment-matrix-attr.attr-code = p-code
      no-error .
    if  available buf_assortment-matrix-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure assmatat-delete :

  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    define buffer buf_assortment-matrix-attr for ub.assortment-matrix-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run assmatat-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_assortment-matrix-attr exclusive-lock
      where
         buf_assortment-matrix-attr.asmt-id    = p-asmt-id
        and buf_assortment-matrix-attr.db-num    = p-db-num
        and buf_assortment-matrix-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_assortment-matrix-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_assortment-matrix-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure assmatat-news :

define input  parameter p-code           as character no-undo . /* код атрибута */
define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    case p-code :
      &scop attr-code assmatat-RootShablon
      {&attr-news-code}

      /* сюда добавлять новые параметры атрибуты ассортиментной матрицы */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code) .
      end.
    end.
  end.
end procedure.


/*секция pop-up меню при ручном редактировании */
procedure assmatat-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибуты ассортиментной матрицы */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure assmatat-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    case p-code :

      /* сюда добавлять новые параметры атрибуты ассортиментной матрицы */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ассортиментной матрицы &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure attr-write :
   define input  parameter iBuffHand as handle no-undo.
   define input  parameter iCode           as character no-undo . /* код атрибута */
   define input  parameter iValue          as character no-undo . /* Значение атрибута */
   do
   on error undo, return error
   :
      define variable vWhere as character no-undo.
      define variable vTables as character no-undo.
      define variable vTablesAttr as character no-undo.
      define variable vBhTbl as handle no-undo.
      define variable vGroupObj as character no-undo.
      
      vTables = iBuffHand:table.
      vTablesAttr = vTables + "-attr".
      run gen-where-keyr-tab  in this-procedure 
                   (vTables + "-attr", 
                    vTables, 
                    vTables + "-attr", 
                    iBuffHand, 
                    "ub",
                    ?,  
                    output vWhere).
/*      vWhere = substitute("FOR EACH &1 &2 ",vTables + "-attr",vWhere).*/
      create buffer vBhTbl for table vTablesAttr .
      vGroupObj = iBuffHand:buffer-field ("GroupObj"):buffer-value ()no-error.
      if error-status:error
      then do:
         vBhTbl:find-first( substitute("&1 and &2.attr-code eq 'GroupObj'",vwhere,vTablesAttr), no-lock ) no-error .
         vGroupObj = if vBhTbl:available then vBhTbl:buffer-field ("attr-value"):buffer-value () else vTables.
      end.
      run attr-Check-group(vGroupObj,iCode,iValue) no-error.
      if error-status:error
      then
         return error return-value.
      find first xattr where Xattr.GroupObj-code eq  vGroupObj 
                         and Xattr.Xattr-Code    eq  iCode
      no-lock no-error.
      if available  Xattr
      then do trans:
         vBhTbl:find-first( substitute("&1 and &2.attr-code eq '&3'",vwhere,vTablesAttr,iCode), exclusive-lock ) no-error .
         if vBhTbl:available
         then do:
            vBhTbl:buffer-field ("attr-value"):buffer-value () = iValue.
         end.
         else do :
            define variable v-field-list as character no-undo.
            define variable vi as integer no-undo.
            run gen-key-field in this-procedure ( input vTables 
                                                 ,output v-field-list
                                              ).
            vBhTbl:buffer-create ().
            do vi = 1 to num-entries(v-field-list,{&delim-key}):
               vBhTbl:buffer-field (entry(vi,v-field-list,{&delim-key})):buffer-value () = iBuffHand:buffer-field (entry(vi,v-field-list,{&delim-key})):buffer-value ().
            end.
            vBhTbl:buffer-field ("attr-code") :buffer-value () =  iCode.
            vBhTbl:buffer-field ("attr-value"):buffer-value () =  if Xattr.Data-Type eq {&ABL-datatype-Decimal}
                                                                  then string(decimal (ivalue)) 
                                                                  else if Xattr.Data-Type eq {&ABL-datatype-Date}
                                                                  then string(date    (ivalue)) 
                                                                  else if Xattr.Data-Type eq {&ABL-datatype-integer}
                                                                  then string(integer (ivalue)) 
                                                                  else if Xattr.Data-Type eq {&ABL-datatype-Logical}
                                                                  then string(logical (ivalue))
                                                                  else                 ivalue no-error.
            if error-status:error
            then
               return error error-status:get-message (1).                                                      
            vBhTbl:buffer-field ("attr-value"):buffer-value () = iValue.
         end.
      end.
      else do:
         return error substitute ("Для группы &1 нет реквизита",vGroupObj,iCode).
      end.
   end.
   finally:
      delete object vBhTbl no-error.
   end.
end procedure.

procedure attr-Check-group :
   define input  parameter iGroupObj       as character no-undo.
   define input  parameter iCode           as character no-undo . /* код атрибута */
   define input  parameter iValue          as character no-undo . /* Значение атрибута */
   do
   on error undo, return error
   :
     /* define variable vWhere as character no-undo.
      define variable vTables as character no-undo.
      define variable vTablesAttr as character no-undo.
      define variable vBhTbl as handle no-undo.
      define variable vGroupObj as character no-undo. */
      
      define variable vdec as character  no-undo.
      define variable vPos as integer no-undo.
      define variable vMaxDec as decimal no-undo init ?.
      define variable vMinDec as decimal no-undo init ?.
      define variable vMaxDat as date no-undo init ?.
      define variable vMinDat as date no-undo init ?.
      define variable vMaxStr as character  no-undo.
      define variable vMinStr as character  no-undo.
      define variable vValDec as decimal no-undo.
      define variable vValDat as date    no-undo.
      define variable vValLog as logical no-undo.
   
      
      find first xattr where Xattr.GroupObj-code eq  GroupObj 
                         and Xattr.Xattr-Code    eq  iCode
      no-lock no-error.
      if available  Xattr
      then do:
         if Xattr.Data-Type eq {&ABL-datatype-Decimal}
         then do:
            vValDec = decimal (ivalue) no-error.
            if error-status:error
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do: 
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindec = decimal (vminstr)no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdec = decimal (vmaxStr)no-error.
               end.
                              
            end.
            vdec =  replace(entry(1,Xattr.Data-Format,"."),",","").
            if vdec begins "-"
            then do:
               assign
                  vmindec = decimal("-" + fill("9",length(vdec) - 1) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "" ) when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec) - 1) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "")  when vmaxdec eq ?
               .
            end.
            else
               assign 
                  vmindec = 0                                                                                                               when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec)    ) + if Xattr.Accuracy > 0 then ("." + fill("9",Xattr.Accuracy)) else "") when vmaxdec eq ?
               .
            if vmindec > vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть больше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmindec,vValDec).
            if vmaxdec < vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть меньше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmaxdec,vValDec).
         end.
         else if Xattr.Data-Type eq {&ABL-datatype-Date}
         then do :
            vValDat = date (ivalue) no-error.
            if error-status:error
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do:
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindat = date  (vminstr) no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdat = date (vmaxStr) no-error.
                  if vmindat > vValDat
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно быть больше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmindat,vValDat).
                  if vmaxdat < vValDat
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно быть меньше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmaxdat,vValDat).
         
               end.
               
            end.
         end.
         else if Xattr.Data-Type eq {&ABL-datatype-integer}
         then do:
            vValDec = integer (ivalue) no-error.
            if error-status:error
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            if vValDec ne decimal (ivalue)
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть целым числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
            if Xattr.Validation ne ""
            then do:
               vpos = index(Xattr.Validation,"<<").
               if vpos ne 0
               then do:
                  vminstr = substring(Xattr.Validation,1,vpos - 1).
                  vmaxStr = substring(Xattr.Validation,vpos + 2).
                  if vminstr ne ""
                  then
                     vmindec = integer  (vminstr)no-error.
                  if vmaxStr ne ""
                  then
                     vmaxdec = integer (vmaxStr)no-error.
               end.
                              
            end.
            vdec =  replace(entry(1,Xattr.Data-Format,"."),",","").
            if vdec begins "-"
            then do:
               assign
                  vmindec = decimal("-" + fill("9",length(vdec) - 1)  ) when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec) - 1)  ) when vmaxdec eq ?
               .
            end.
            else
               assign 
                  vmindec = 0                                          when vmindec eq ?
                  vmaxdec = decimal(      fill("9",length(vdec)    ) ) when vmaxdec eq ?
               .
            if vmindec > vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть больше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmindec,vValDec).
            if vmaxdec < vValDec
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть меньше или равно &3.  Переданное значение '&4'",iGroupObj,iCode,vmaxdec,vValDec).
         end. 
         else if Xattr.Data-Type eq {&ABL-datatype-Logical}
         then do:
            vValLog = logical (ivalue) no-error.
            if    error-status:error
               or (    Xattr.Validation ne ""
                   and num-entries(Xattr.Validation,"/") eq 2
                   and ivalue ne entry(1,Xattr.Validation,"/")
                   and ivalue ne entry(2,Xattr.Validation,"/"))
            then
               return error substitute ("Для группы &1 значение атрибута &2 должно быть числом. Переданное значение '&3'",iGroupObj,iCode,ivalue).
         end.
         else do:
            if Xattr.Domain-Code ne ""
            then do:
               define variable vParent as character no-undo.
               define variable vi      as integer no-undo.
               define variable vValStr as character no-undo.
               define buffer code for code.
               
               vParent = replace(Xattr.Domain-Code, "\", {&delim-par}).
               do vi = 1 to num-entries(ivalue):
                  vValStr = entry(vi,ivalue).
                  find first code where code.parent  eq  vParent 
                                    and code.status_ ne {&bef-deleted-status-int}
                                    and code.code    eq vValStr
                  no-lock no-error.
                  if not available code
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно в справочнике &4. Переданное значение '&3'",iGroupObj,iCode,vValStr,Xattr.Domain-Code).
                  
               end.
                
            end.
            if     Xattr.Validation ne ""
            then do:
               do vi = 1 to num-entries(ivalue):
                  vValStr = entry(vi,ivalue).
                  
                  if not can-do(Xattr.Validation, vValStr)
                  then
                     return error substitute ("Для группы &1 значение атрибута &2 должно удовлетворять маске '&4'. Переданное значение '&3'",iGroupObj,iCode,vValStr,Xattr.Validation).
                  
               end.
            end.
            
         end.
   
      end.
      else do:
         return error substitute ("Для группы &1 нет реквизита",iGroupObj,iCode).
      end.
   end.
   
end procedure.


procedure attr-read :
   define input   parameter iBuffHand as handle no-undo.
   define input   parameter iCode           as character no-undo . /* код атрибута */
   define output  parameter oValue          as character no-undo . /* Значение атрибута */
   do
   on error undo, return error
   :
      define variable vWhere as character no-undo.
      define variable vTables as character no-undo.
      define variable vTablesAttr as character no-undo.
      define variable vBhTbl as handle no-undo.
      
      vTables = iBuffHand:table.
      vTablesAttr = vTables + "-attr".
      run GenWhereKeyrTab in this-procedure 
                   (vTables + "-attr", 
                    vTables, 
                    vTables + "-attr", 
                    iBuffHand, 
                    "ub",
                    ?,  
                    output vWhere).
/*      vWhere = substitute("FOR EACH &1 &2 ",vTables + "-attr",vWhere).*/
      create buffer vBhTbl for table vTablesAttr .
      oValue = iBuffHand:buffer-field (iCode):buffer-value ()no-error.
      if error-status:error
      then do:
         vBhTbl:find-first( substitute("&1 and &2.attr-code eq '&3'",vwhere,vTablesAttr,icode), no-lock ) no-error .
         oValue = if vBhTbl:available then vBhTbl:buffer-field ("attr-value"):buffer-value () else ?.
      end.
   end.
   finally:
      delete object vBhTbl no-error.
   end.
end procedure.

/* Возвращает является ли товар с экземплярным учетом */
procedure isExemplarGoods:
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  
  define variable vAttrValue as character no-undo.
  define variable vAttrType  as character no-undo.
  define variable EDOParSec  as class ibs.th.gbl.env.prmtrs.edo .
  def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
  run gbl/getobjsrvhndl.p (input-output ObjSrv).
  
  run gds-attr-value in this-procedure
      (input  p-gds-code
      ,input  {&attr-mark-type}
      ,output vAttrValue
      ,output vAttrType
      ) .

  if vAttrValue <> "" then
  do:
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
    o-result = EDOParSec:GetIsEDOForType(vAttrValue).
  end.
  else 
    o-result = false.
end procedure.


/* Возвращает является ли товар с объемно-артикульным учетом */
procedure isVolumArticGoods:
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.

  define variable vAttrValue as character no-undo.
  define variable vAttrType  as character no-undo.
  define variable EDOParSec  as class ibs.th.gbl.env.prmtrs.edo .
  def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
  run gbl/getobjsrvhndl.p (input-output ObjSrv).

  run gds-attr-value in this-procedure
      (input  p-gds-code
      ,input  {&attr-mark-type}
      ,output vAttrValue
      ,output vAttrType
      ) .
  if vAttrValue <> "" then
  do:
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
    o-result = EDOParSec:GetIsArticForType(vAttrValue).
  end.
  else
    o-result = false.
end procedure.
