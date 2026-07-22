/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по продажам ниже учетной цены

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


/* это просто повтор часть для r-ben-d2.i */
    do ii = 1 to ( NumObj ) :
      assign
        TitleStr1 = TitleStr1 + ",,"
        TitleStr2 = TitleStr2 + ",,"
        sheetf.Sizes    = sheetf.Sizes    + ",9,9"
     .
    end.

    assign
      NumColumn = NumColumn + 2
      TitleStr3 = TitleStr3 + "Всего,,"
      TitleStr4 = TitleStr4 + "шт,ст-ть,"
    .

    for each obj-list :
      assign
        TitleH3 = TitleH3 + "," + string(NumColumn) + ":" + string(NumColumn + 1 )
        NumColumn = NumColumn + 2
        TitleStr3 = TitleStr3 + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")" + ",,"
        TitleStr4 = TitleStr4 + "шт,ст-ть,"
      .
    end.

/* $Workfile$ e n d */