/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры обработки списков

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

diff-list    Вычитание одного списка из другого
      parfirst-list  - первый список
      parsecond-list - второй список
      pardelim       - разделитель

      Возвращаемое значение: строка
        все элементы списка parfirst-list исключая элементы списка parsecond-list

      Пример:
        elem1,elem2,elem3    elem2,elem4  ->  elem1,elem3

add-list    Объединение элементов двух списков
            Возвращает список уникальных элементов

cross-list  Пересечение элементов двух списков
            Возвращает список уникальных элементов

radio-label возвращает лейбл кнопки радио-баттона -
             чтобы избежать  ошибок при переводе
             пример ввызова для кнопки RecipeType
             было

             DEFINE VARIABLE RSOption AS CHARACTER
             VIEW-AS RADIO-SET HORIZONTAL
             RADIO-BUTTONS
             "Хихи", 1,
             "Хаха", 2
             size 70.25 by 1
             BGCOLOR 8 FGCOLOR 0  NO-UNDO.


             g#log =  RS-Option:disable( "Хаха"  ) .

             стало
             g#log = RSOption:disable(radio-label(string(1), RSOption:radio-buttons)).
*/

function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).

/*    del-list = replace (del-list, "," + string (recid (parts)), "").*/
/*    del-list = replace (del-list, string (recid (parts)) + ",", "").*/
/*    del-list = replace (del-list, string (recid (parts)), "").*/

  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.

  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".

  def var v-num-parfirst-list as integer no-undo .

  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .

  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.

  return v-result-list .

end function.

function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).

  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.

  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".

  def var v-num-parfirst-list as integer no-undo .

  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .

  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.

  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .

  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.

  return v-result-list .

end function.

function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).

  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.

  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".

  def var v-num-parfirst-list as integer no-undo .

  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .

  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .

end function.



function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .

 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.


function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.

FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :

  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.

  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".

  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .

END FUNCTION.


/* $Workfile$ e n d */