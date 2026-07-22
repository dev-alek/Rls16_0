/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Генерация порядкового номера документа на основании даты закрытия документа и номера смены

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if defined(factord_i) = 0 &then

&glob factord_i

procedure factord :

  define input  parameter p-fact-date            as date    no-undo . /* фактическая дата закрытия документа  */
  define input  parameter p-fact-time            as integer no-undo . /* фактическое время закрытия документа */
  define input  parameter p-fact-num             as integer no-undo . /* фактический номер закрытия документа */
  define input  parameter p-shift-date           as date    no-undo . /* дата начала смены для документа      */
  define input  parameter p-shift-num            as integer no-undo . /* номер смены для документа            */
  define input  parameter p-shift-on             as logical no-undo . /* на объекте включены смены            */
  define output parameter p-fact-order           as decimal no-undo . /* порядковый номер закрытия документа  */
  define output parameter p-shift-end-fact-order as decimal no-undo . /* номер конца смены   используется для АРХИВА */
  define output parameter p-day-end-fact-order   as decimal no-undo . /* номер конца дня     используется для АРХИВА */

  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".

  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.

  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .

  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.

  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.

  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.

  if p-shift-on = true
  then do:
    /* смены включены */
    /* должны быть заданы дата и номер смены */
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.

    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    /* смены выключены */
    /* присваиваем значения по умолчанию */
    assign
      p-shift-date = p-fact-date
      p-shift-num  = {&max-shift-num}
    .
  end.

  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.

  if p-shift-num < {&min-shift-num}
  or p-shift-num > {&max-shift-num}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * {&arh-delta}
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .

  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - {&arh-delta} /* arh-delta зарезервировано для сменной сверки */
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.

end procedure. /* factord */

procedure day-begin-fact-order :

  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .

  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.

  end.

end procedure. /* day-begin-fact-order */


procedure factord-max-fact-order :

  define output parameter p-max-fact-order as decimal   no-undo .

  /* максимально возможная дата в системе */
  /* 1 января 5000 года */

  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000) /* p-fact-date            */
      ,output p-max-fact-order /* p-day-begin-fact-order */
      ) .
  end.

end procedure. /* factord-max-fact-order */


procedure factord-cut-archive :

  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .

  define variable v-fact-order as decimal   no-undo .

  define buffer buf_shift-obj for ub.shift-obj .

  do
  on error undo, return error return-value
  :

    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'shift-on=request'"
      p-shift-on
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> {&sht-closed}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = {&sht-closed}
        then do:
          /* дата актуальная и последняя */
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" {&sht-closed} skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.

    /* определяем fact-order для новых начальных остатков архивов */
    run factord in this-procedure
      (input  p-fact-date             /* p-fact-date            */
      ,input  1                       /* p-fact-time            */
      ,input  1                       /* p-fact-num             */
      ,input  p-shift-date            /* p-shift-date           */
      ,input  p-shift-num             /* p-shift-num            */
      ,input  p-shift-on              /* p-shift-on             */
      ,output v-fact-order            /* p-fact-order           */
      ,output p-shift-end-fact-order  /* p-shift-end-fact-order */
      ,output p-day-end-fact-order    /* p-day-end-fact-order   */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.

end procedure. /* factord-cut-archive */


procedure factord-lock-shift :

  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .

  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'shift-on=request'"
      v-shift-on
      no-error
    }
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.

    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> {&sht-closed}
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = {&sht-closed}
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.

end procedure. /* factord-lock-shift */

procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo . /* фактическая дата закрытия документа  */
  define output parameter p-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */

  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.

    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.

end procedure. /* factord-end-day */


procedure factord-to-date :

  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .

  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.

    /* здесь может быть любая дата */
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.

end procedure. /* factord-date */

procedure factord-to-fact-num :

  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .

  define variable v-fact-order-trunc as decimal no-undo .

  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.

    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.

end procedure. /* factord-to-fact-num */

procedure factord-to-shift-num :

  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .

  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .

  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.

    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .

  end.

end procedure. /* factord-to-fact-num */

&endif
/* $Workfile$ e n d */