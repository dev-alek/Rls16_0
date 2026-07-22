/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение уникального бар-кода  = артикулу товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

входной параметр - предлагаемый код
выходной параметр - возможность генерации

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

procedure chk-b-code:
define input parameter p-silence as logical no-undo .
define input param b-c like ub.bar-code.b-code no-undo.
define output param p-log as log no-undo.

  /*
  define variable par-type as character no-undo.
  define variable conf-par as character no-undo.                  /* для чтения параметра конфигурации */
  */
  define variable l-code as integer no-undo.
  define variable v-mes as character no-undo .
  define variable v-param-type{&vssseq} as character no-undo .
  define variable v-value-character{&vssseq} as INTEGER no-undo .
  define variable v-value-date{&vssseq} as date no-undo .
  define variable v-value-decimal{&vssseq} as decimal no-undo .
  define variable v-value-integer{&vssseq} AS integer no-undo .
  define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
  define variable v-tth{&vssseq} as handle no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl.
  define buffer b-c-r for ub.code-range.
  define buffer buf_code-range for ub.code-range .

  do
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :

    find first buf_sys-ctrl no-lock.
    p-log = no.

    run adm/shattri.p (
        input "get":U
        ,input  {&db}
        ,input  buf_sys-ctrl.db-num
        ,input  {&attr-code-range}
        ,input  {&attr-code-range_cdrgbcgb} /*p-param-code*/
        ,output v-value-character{&vssseq}
        ,output v-value-date{&vssseq}
        ,output v-value-decimal{&vssseq}
        ,output v-value-integer{&vssseq}
        ,output v-value-logical{&vssseq}
        ,output v-param-type{&vssseq}
        ,INPUT-OUTPUT table-handle v-tth{&vssseq}
        ) no-error .

    if error-status :error then do:
      delete object v-tth{&vssseq}.
      v-mes = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
      if not p-silence then
      message
      v-mes
      view-as alert-box error.
      p-log = no.
      undo, return error v-mes.
    end.
    delete object v-tth{&vssseq}.


    find first buf_code-range
      where buf_code-range.range-type = {&gbl-bc-code}
        and buf_code-range.last-code >= b-c
        and buf_code-range.db-num = g#db-num
    use-index last-codei
  no-lock no-error . /* хватаем с no-lock т.к. еще не знаем есть ли вообще такой диапазон
  а если есть подойдет ли он нам */

    if available buf_code-range and buf_code-range.first-code <= b-c then do:
      case buf_code-range.stts:
      when "a" then do:
          if buf_code-range.db-num <> buf_sys-ctrl.db-num then do:
          assign
          v-mes = substitute("Нельзя использовать активный диапазон чужой БД для генерации бар-кодов в БД").
          if not p-silence then
          message v-mes
          view-as alert-box error.
          p-log = no.
          undo, return error v-mes.
        end.
        p-log = yes.
        /*
        if current-value(s-bcgb-code, {&db-name_schema}) > b-c then  /* попали в "дырку" для бар-кодов
        спокойно можем вводить */
          p-log = yes.
        else do: /* нельзя - эта часть диапазона используется в настоящий момент */
          p-log =  no.
          undo, return error
          substitute("значение первого свободного кода (sequence <s-bcgb-code>) &2, который может быть создан, > заданного кода &1"
                      , b-c, current-value(s-bcgb-code, {&db-name_schema})).
        end.
        */
      end. /* для активного диапазона */
      when "f" then do:
          if buf_code-range.db-num = -1
          or buf_code-range.db-num <> buf_sys-ctrl.db-num
          then do: /* менять можно только для несуществующей базы
с db-num = -1 */
          assign
            v-mes = substitute("Нельзя использовать свободный диапазон БД для генерации бар-кодов:&1" +
                               "текущая БД &2, диапазон (&3 - &4) для БД &5&1"
                               ,{&new-line}
                               ,buf_sys-ctrl.db-num
                               ,buf_code-range.first-code
                               ,buf_code-range.last-code
                               ,buf_code-range.db-num
                               ).
          if not p-silence then
          message v-mes
          view-as alert-box error.
          p-log = no.
          undo, return error v-mes .
        end.
/* надо захватить диапазон если это возможно чтобы сменить его статус */
          find b-c-r where recid(b-c-r) = recid(buf_code-range) exclusive no-error.
        if (not available b-c-r) or (b-c-r.db-num <> buf_sys-ctrl.db-num) then do:
/* кто то уже успел поменять buf_code-range и теперь с ним работать нельзя т.к. он либо
активный либо относится к конктреной БД */
          p-log = no.
          undo, return error.
        end.
        assign
          b-c-r.stts = "u"
            b-c-r.db-num = buf_sys-ctrl.db-num
          p-log = yes.
      end.
      when "u" then do: /*   ну уж если сюда забрались то все нормально */
          if (buf_code-range.db-num > 0 and buf_sys-ctrl.db-num = 0) or
             (buf_sys-ctrl.db-num <> 0 and buf_code-range.db-num <> buf_sys-ctrl.db-num)  then do:
          assign
          v-mes = substitute("Нельзя использовать использованный чужой диапазон БД для генерации бар-кодов в БД").
          if not p-silence then
          message v-mes
          view-as alert-box error.
          p-log = no.
          undo, return error v-mes.
        end.
        assign
          p-log = yes.
      end.
    end case.
  end. /* if avail */
    else do: /* ну не повезло надо интервалы создавать до тех пор пока бар-код не попадет в интервал */
      if buf_sys-ctrl.db-num <> 0 then do:
      assign
      v-mes = substitute("Нельзя создавать диапазоны в УБД ").
      if not p-silence then
      message v-mes
      view-as alert-box error.
      undo, return error v-mes.
    end.
    find first buf_code-range
      where buf_code-range.range-type = {&gbl-bc-code}
        and buf_code-range.last-code >= b-c
        and buf_code-range.first-code <= b-c
    no-lock no-error .
    if available buf_code-range
    and buf_code-range.db-num <> g#db-num then do:
      assign
      v-mes = substitute("Диапазон для кода &1 (&2-&3) принадлежит БД &4"
                          , b-c
                          , buf_code-range.first-code
                          , buf_code-range.last-code
                          , buf_code-range.db-num
                  ).
      if not p-silence then
      message v-mes
      view-as alert-box error.
      undo, return error v-mes.
    end.
      _l-code:
      do while true :
        /* процедура создания нового свободного code-range для  */
        run new-bcod-gen-code-range in this-procedure ( input g#db-num
                                                       ,input {&gbl-bc-code}).
        find first buf_code-range where
          buf_code-range.range-type = {&gbl-bc-code}
            and buf_code-range.db-num = g#db-num
            and buf_code-range.last-code >= b-c
            and buf_code-range.first-code <= b-c  no-lock no-error .
        if available buf_code-range then do:
          find b-c-r where recid(b-c-r) = recid(buf_code-range) exclusive .
          b-c-r.stts = 'u':U.
          p-log = yes.
          leave _l-code.
        end.
    end.
  end.
end.
end procedure.

/* $Workfile$ e n d */