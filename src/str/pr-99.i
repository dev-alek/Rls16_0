/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Алгоритм округления продажной цены

Автор: Чернова Светлана Александровна
Дата создания: 03/24/06
Author: Svetlana Chernova
Creation date: 03/24/06

Параметры
{1} - округляемая цена (decimal)
{2} - метод округления (character)
{3} - коэффициент округления (decimal)

*/

&scop round-method {2}
&scop round-base   {3}

case {&round-method} :
  when {&pr-round-9end} then do:
    if {1} < 29 then do:
      if ({1} - truncate ({1}, 0)) <> 0 then do:
        assign
          {1} = truncate ({1}, 0) + 1
        .
      end.
    end.
    else do:
      if ({1} modulo 10) < 3 then do:
        assign
          {1} = ({1} - ({1} modulo 100)) /* без десятков */
              + ( truncate ((({1} modulo 100) / 10), 0) /* цифра для уменьшения */
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          {1} = ({1} - ({1} modulo 100)) /* без десятков */
              + ( truncate ((({1} modulo 100) / 10), 0) /* цифра для уменьшения */
                ) * 10
              + 9
        .
      end.
      assign
        {1} = round ({1}, 0)
      .
    end.
  end.

  when {&pr-round-9-99end} then do:
    if {1} < {&round-base} then do:
      assign
        {1} = truncate ({1}, 0) + 0.99
      .
    end.
    else do:
      assign
        {1} = truncate ({1} / 10 , 0) * 10 + 9.99
      .
    end.
  end.


  when {&pr-round-integer} then do:
    assign
      {1} = round ({1}, 0)
    .
  end.

  when {&pr-round-select} then do:
    if {&round-base} <> 0 then do:
      assign
        {1} = round ({1} / {&round-base}, 0) * {&round-base}
      .
      if {1} = 0 then do:
        assign
          {1} = {&round-base}
        .
      end.
    end.
  end.

  when {&pr-round-up} then do:
    if {&round-base} <> 0 then do:
      if truncate ( {1} / {&round-base}, 0 ) <> ({1} / {&round-base}) then do:
        assign
          {1} = truncate ({1} / {&round-base}, 0) * {&round-base} + {&round-base}
        .
      end.
    end.
    if {1} = 0 then do:
      assign
        {1} = {&round-base}
      .
    end.
  end.

  when {&pr-round-coef} then do:
    if {&round-base} <> 0 then do:
      assign
        {1} = {1} * {&round-base}
      .
    end.
  end.

  when {&pr-round-off} then do:
    /* округление отключено */
  end.

  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" {&round-method} skip
      "round-base"   {&round-base}   skip
      "price"        {1}             skip
      view-as alert-box error .
  end.
end.