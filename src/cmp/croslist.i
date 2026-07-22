/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06


cross-list   Пересечение списков
      parfirst-stream  - первый список
      parsecond-stream - второй список
      pardelim         - разделитель

      Возвращаемое значение: логическая переменная,
        true  - если хотя бы один элемент списка parfirst-stream
                входит в список parsecond-stream
        false - в противном случае

*/

function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).

  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.

  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .

  assign
    varresult-cross = no
  .

  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .

  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.

  return varresult-cross .

end function.

/* $Workfile$ e n d */