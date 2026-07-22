/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

получение суммы прописью

Автор: Булгаков Андрей Николаевич
Дата создания: 09/20/94
Author: Andrew Bulgakoff
Creation date: 09/20/94

*/

assign
  Word = "":U
.
case substring( Formatted, II, 1 ) :
  when "0" then do:
    assign
      Word = "{1}"
    .
  end.
  when "1" then do:
    assign
      Word = "{2}"
    .
  end.
  when "2" then do:
    assign
      Word = "{3}"
    .
  end.
  when "3" then do:
    assign
      Word = "{4}"
    .
  end.
  when "4" then do:
    assign
      Word = "{5}"
    .
  end.
  when "5" then do:
    assign
      Word = "{6}"
    .
  end.
  when "6" then do:
    assign
      Word = "{7}"
    .
  end.
  when "7" then do:
    assign
      Word = "{8}"
    .
  end.
  when "8" then do:
    assign
      Word = "{9}"
    .
  end.
  when "9" then do:
    assign
      Word = "{10}"
    .
  end.
end case. /* substring( Formatted, II, 1 ) */

/* $Workfile$   E n d */

