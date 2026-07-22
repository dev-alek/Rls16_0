/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Название фрейма при установке фильтра

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/15/03
Author: Bakhtadze Natalya
Creation date: 10/15/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .

      &if "{1}" <> "no-button" &then
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
      &endif

      &if "{2}" <> "" &then
      assign
        {2} :bgcolor = red_color
      .
      &endif

    end.
    else do:
      &if "{1}" <> "no-button" &then
      assign
        b-sch :tooltip = ""
      .
      &endif
      &if "{2}" <> "" &then
      assign
        {2} :bgcolor = grey_color
      .
      &endif
    end.

  end. /* do with frame */

end procedure.

/* $Workfile$ e n d */