/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кодирование и декодирование четырех логических полей в два логических и одно текстовое поля базы данны

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/10/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure arhisatr_encode-attr :

  define input  parameter p-attr-calc        as logical   no-undo .
  define input  parameter p-attr-del         as logical   no-undo .
  define input  parameter p-attr-disable     as logical   no-undo .
  define input  parameter p-attr-rest        as logical   no-undo .
  define output parameter p-attr-encode-calc as logical   no-undo .
  define output parameter p-attr-encode-del  as logical   no-undo .
  define output parameter p-attr-encode-ps   as character no-undo .

  do
  on error undo, return error return-value
  :
    if p-attr-calc = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Рассчёт архива' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-attr-del = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Требуется первоначальный расчёт архива' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-attr-disable = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Расчет архива выключен' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-attr-rest = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Атрибут 'Удаление восстановление архива' имеет неопределённое значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-total-value    as integer   no-undo .
    define variable v-encode-value-1 as integer   no-undo .
    define variable v-encode-value-2 as integer   no-undo .

    assign
      v-total-value = (if p-attr-calc
                       then 1
                       else 0
                      )
                      +
                      (if p-attr-del
                       then 2
                       else 0
                      )
                      +
                      (if p-attr-rest
                       then 4
                       else 0
                      )
    .
    assign
      v-encode-value-1 = truncate(v-total-value / 3, 0)
      v-encode-value-2 = v-total-value modulo 3
    .

    case v-encode-value-1
    :
      when 0
      then do:
        assign
          p-attr-encode-calc = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-encode-calc = true
        .
      end.
      when 2
      then do:
        assign
          p-attr-encode-calc = ?
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-encode-value-1" v-encode-value-1 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    case v-encode-value-2
    :
      when 0
      then do:
        assign
          p-attr-encode-del = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-encode-del = true
        .
      end.
      when 2
      then do:
        assign
          p-attr-encode-del = ?
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-encode-value-2" v-encode-value-2 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    assign
      p-attr-encode-ps = string(p-attr-disable)
    .

    define variable v-check-p-attr-calc    as logical   no-undo .
    define variable v-check-p-attr-del     as logical   no-undo .
    define variable v-check-p-attr-disable as logical   no-undo .
    define variable v-check-p-attr-rest    as logical   no-undo .

    run arhisatr_decode-attr in this-procedure
      (input  p-attr-encode-calc
      ,input  p-attr-encode-del
      ,input  p-attr-encode-ps
      ,output v-check-p-attr-calc
      ,output v-check-p-attr-del
      ,output v-check-p-attr-disable
      ,output v-check-p-attr-rest
      ) .
    if p-attr-calc    <> v-check-p-attr-calc
    or p-attr-del     <> v-check-p-attr-del
    or p-attr-disable <> v-check-p-attr-disable
    or p-attr-rest    <> v-check-p-attr-rest
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Не совпадают раскодированные значения" skip
        "p-attr-calc"    p-attr-calc    skip
        "p-attr-del"     p-attr-del     skip
        "p-attr-disable" p-attr-disable skip
        "p-attr-rest"    p-attr-rest    skip
        "v-check-p-attr-calc"    v-check-p-attr-calc    skip
        "v-check-p-attr-del"     v-check-p-attr-del     skip
        "v-check-p-attr-disable" v-check-p-attr-disable skip
        "v-check-p-attr-rest"    v-check-p-attr-rest    skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* arhisatr_encode-attr */


procedure arhisatr_decode-attr :

  define input  parameter p-attr-decode-calc as logical   no-undo .
  define input  parameter p-attr-decode-del  as logical   no-undo .
  define input  parameter p-attr-decode-ps   as character no-undo .
  define output parameter p-attr-calc        as logical   no-undo .
  define output parameter p-attr-del         as logical   no-undo .
  define output parameter p-attr-disable     as logical   no-undo .
  define output parameter p-attr-rest        as logical   no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-total-value    as integer   no-undo .
    define variable v-encode-value-1 as integer   no-undo .
    define variable v-encode-value-2 as integer   no-undo .

    case p-attr-decode-calc
    :
      when false
      then do:
        assign
          v-encode-value-1 = 0
        .
      end.
      when true
      then do:
        assign
          v-encode-value-1 = 1
        .
      end.
      when ?
      then do:
        assign
          v-encode-value-1 = 2
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение p-attr-decode-calc" p-attr-decode-calc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    case p-attr-decode-del
    :
      when false
      then do:
        assign
          v-encode-value-2 = 0
        .
      end.
      when true
      then do:
        assign
          v-encode-value-2 = 1
        .
      end.
      when ?
      then do:
        assign
          v-encode-value-2 = 2
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение p-attr-decode-del" p-attr-decode-del skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    assign
      v-total-value = v-encode-value-1 * 3
                    + v-encode-value-2
    .

    define variable v-decode-value-1 as integer   no-undo .
    define variable v-decode-value-2 as integer   no-undo .
    define variable v-decode-value-3 as integer   no-undo .

    assign
      v-decode-value-1 = v-total-value modulo 2
    .
    assign
      v-total-value = truncate(v-total-value / 2, 0)
    .
    assign
      v-decode-value-2 = v-total-value modulo 2
    .
    assign
      v-total-value = truncate(v-total-value / 2, 0)
    .
    assign
      v-decode-value-3 = v-total-value
    .

    case v-decode-value-1
    :
      when 0
      then do:
        assign
          p-attr-calc = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-calc = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-decode-value-1" v-decode-value-1 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    case v-decode-value-2
    :
      when 0
      then do:
        assign
          p-attr-del = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-del = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-decode-value-2" v-decode-value-2 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    case v-decode-value-3
    :
      when 0
      then do:
        assign
          p-attr-rest = false
        .
      end.
      when 1
      then do:
        assign
          p-attr-rest = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение v-decode-value-3" v-decode-value-3 skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    assign
      p-attr-disable = lookup(p-attr-decode-ps, 'true,yes':u) > 0
    .
  end.

end procedure. /* arhisatr_decode-attr */

function arhisatr_get-calc returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .

  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc /* p-attr-decode-calc */
    ,input  p-attr-decode-del  /* p-attr-decode-del  */
    ,input  p-attr-decode-ps   /* p-attr-decode-ps   */
    ,output v-attr-calc        /* p-attr-calc        */
    ,output v-attr-del         /* p-attr-del         */
    ,output v-attr-disable     /* p-attr-disable     */
    ,output v-attr-rest        /* p-attr-rest        */
    ) .

  return v-attr-calc .

end function .

function arhisatr_get-del returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .

  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc /* p-attr-decode-calc */
    ,input  p-attr-decode-del  /* p-attr-decode-del  */
    ,input  p-attr-decode-ps   /* p-attr-decode-ps   */
    ,output v-attr-calc        /* p-attr-calc        */
    ,output v-attr-del         /* p-attr-del         */
    ,output v-attr-disable     /* p-attr-disable     */
    ,output v-attr-rest        /* p-attr-rest        */
    ) .

  return v-attr-del .

end function .

function arhisatr_get-disable returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .

  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc /* p-attr-decode-calc */
    ,input  p-attr-decode-del  /* p-attr-decode-del  */
    ,input  p-attr-decode-ps   /* p-attr-decode-ps   */
    ,output v-attr-calc        /* p-attr-calc        */
    ,output v-attr-del         /* p-attr-del         */
    ,output v-attr-disable     /* p-attr-disable     */
    ,output v-attr-rest        /* p-attr-rest        */
    ) .

  return v-attr-disable .

end function .

function arhisatr_get-rest returns logical
(input p-attr-decode-calc as logical
,input p-attr-decode-del  as logical
,input p-attr-decode-ps   as character
)
:
  define variable v-attr-calc    as logical   no-undo .
  define variable v-attr-del     as logical   no-undo .
  define variable v-attr-disable as logical   no-undo .
  define variable v-attr-rest    as logical   no-undo .

  run arhisatr_decode-attr in this-procedure
    (input  p-attr-decode-calc /* p-attr-decode-calc */
    ,input  p-attr-decode-del  /* p-attr-decode-del  */
    ,input  p-attr-decode-ps   /* p-attr-decode-ps   */
    ,output v-attr-calc        /* p-attr-calc        */
    ,output v-attr-del         /* p-attr-del         */
    ,output v-attr-disable     /* p-attr-disable     */
    ,output v-attr-rest        /* p-attr-rest        */
    ) .

  return v-attr-rest .

end function .





/* $Workfile$ e n d */