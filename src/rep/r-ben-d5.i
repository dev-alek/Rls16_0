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

  if Itog = no then do:
    {&PutExcel} string(NumLine)                           {&tabulation}
                format-excel-text( temp-BenetTov.artic )  {&tabulation}
                temp-BenetTov.gds-name                    {&tabulation}
    .
    assign   NumLine = NumLine + 1 .

    if use-column1[1] = yes then {&PutExcel}   excel-sum2( temp-BenetTov.sum-prov )    {&tabulation} .
    if use-column1[2] = yes then {&PutExcel}   excel-sum2( temp-BenetTov.sum-beg )     {&tabulation} .
    if use-column1[3] = yes then {&PutExcel}   excel-sum2( temp-BenetTov.sum-end )     {&tabulation} .
  end.

  if use-column1[4] = yes then do:
    for each temp-date
      where temp-date.type = 1
    :
      for each temp-SumObj :
        assign
          temp-SumObj.val = 0
          temp-SumObj.sum = 0
        .
      end.

      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = 1
          and temp-value.data      = temp-date.data
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        assign
          temp-SumObj.val = temp-SumObj.val + temp-value.qnty
          temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
        .
      end.

      assign
        val-all = 0
        sum-all = 0
      .
      for each temp-SumObj :
        assign
          val-all = val-all + temp-SumObj.val
          sum-all = sum-all + temp-SumObj.sum
        .
      end.
      run SumGroup in this-procedure (val-all,sum-all) .

      if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
      for each obj-list :
        find first temp-SumObj
          where temp-SumObj.obj-type = obj-list.obj-type
            and temp-SumObj.obj-code = obj-list.obj-code
          .
        run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
        if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
      end.
    end.
  end.

  if use-column1[5] = yes then do:
    for each temp-SumObj :
      assign
        temp-SumObj.val = 0
        temp-SumObj.sum = 0
      .
    end.

    for each temp-value
      where temp-value.artic     = temp-BenetTov.artic
        and temp-value.prod-type = temp-BenetTov.prod-type
        and temp-value.prod-code = temp-BenetTov.prod-code
        and temp-value.type      = 1
      :
      find first temp-SumObj
        where temp-SumObj.obj-type = temp-value.obj-type
          and temp-SumObj.obj-code = temp-value.obj-code
        .
      assign
        temp-SumObj.val = temp-SumObj.val + temp-value.qnty
        temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
      .
    end.

    assign
      val-all = 0
      sum-all = 0
    .
    for each temp-SumObj :
      assign
        val-all = val-all + temp-SumObj.val
        sum-all = sum-all + temp-SumObj.sum
      .
    end.
    run SumGroup in this-procedure (val-all,sum-all) .

    if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
    for each obj-list :
      find first temp-SumObj
        where temp-SumObj.obj-type = obj-list.obj-type
          and temp-SumObj.obj-code = obj-list.obj-code
        .
      run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
      if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
    end.
  end.

  if use-column1[6] = yes then do:
    for each temp-date
      where temp-date.type = 2
    :
      for each temp-SumObj :
        assign
          temp-SumObj.val = 0
          temp-SumObj.sum = 0
        .
      end.

      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = 2
          and temp-value.data      = temp-date.data
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        assign
          temp-SumObj.val = temp-SumObj.val + temp-value.qnty
          temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
        .
      end.

      assign
        val-all = 0
        sum-all = 0
      .
      for each temp-SumObj :
        assign
          val-all = val-all + temp-SumObj.val
          sum-all = sum-all + temp-SumObj.sum
        .
      end.
      run SumGroup in this-procedure (val-all,sum-all) .

      if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
      for each obj-list :
        find first temp-SumObj
          where temp-SumObj.obj-type = obj-list.obj-type
            and temp-SumObj.obj-code = obj-list.obj-code
          .
        run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
        if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
      end.
    end.
  end.

  if use-column1[7] = yes then do:
    for each temp-SumObj :
      assign
        temp-SumObj.val = 0
        temp-SumObj.sum = 0
      .
    end.

    for each temp-value
      where temp-value.artic     = temp-BenetTov.artic
        and temp-value.prod-type = temp-BenetTov.prod-type
        and temp-value.prod-code = temp-BenetTov.prod-code
        and temp-value.type      = 2
      :
      find first temp-SumObj
        where temp-SumObj.obj-type = temp-value.obj-type
          and temp-SumObj.obj-code = temp-value.obj-code
        .
      assign
        temp-SumObj.val = temp-SumObj.val + temp-value.qnty
        temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
      .
    end.

    assign
      val-all = 0
      sum-all = 0
    .
    for each temp-SumObj :
      assign
        val-all = val-all + temp-SumObj.val
        sum-all = sum-all + temp-SumObj.sum
      .
    end.
    run SumGroup in this-procedure (val-all,sum-all) .

    if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
    for each obj-list :
      find first temp-SumObj
        where temp-SumObj.obj-type = obj-list.obj-type
          and temp-SumObj.obj-code = obj-list.obj-code
        .
      run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
      if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
    end.
  end.

  if use-column1[8] = yes then do:
    for each temp-SumObj :
      assign
        temp-SumObj.val = 0
        temp-SumObj.sum = 0
      .
    end.

    do ii = 1 to 2 :
      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = ii
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        if ii = 2 then do:
          assign
            temp-SumObj.val = temp-SumObj.val - temp-value.qnty
            temp-SumObj.sum = temp-SumObj.sum - temp-value.sum
          .
        end.
        else do:
          assign
            temp-SumObj.val = temp-SumObj.val + temp-value.qnty
            temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
          .
        end.
      end.
    end.

    assign
      val-all = 0
      sum-all = 0
    .
    for each temp-SumObj :
      assign
        val-all = val-all + temp-SumObj.val
        sum-all = sum-all + temp-SumObj.sum
      .
    end.

    run SumGroup in this-procedure (val-all,sum-all) .
    if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
    for each obj-list :
      find first temp-SumObj
        where temp-SumObj.obj-type = obj-list.obj-type
          and temp-SumObj.obj-code = obj-list.obj-code
        .
      run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
      if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
    end.
  end.

  do ii = 3 to 4 :
    if use-column1[ii + 6] = yes then do:
      for each temp-SumObj :
        assign
          temp-SumObj.val = 0
          temp-SumObj.sum = 0
        .
      end.

      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = ii
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        assign
          temp-SumObj.val = temp-SumObj.val + temp-value.qnty
          temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
        .
      end.

      assign
        val-all = 0
        sum-all = 0
      .
      for each temp-SumObj :
        assign
          val-all = val-all + temp-SumObj.val
          sum-all = sum-all + temp-SumObj.sum
        .
      end.
      run SumGroup in this-procedure (val-all,sum-all) .

      if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
      for each obj-list :
        find first temp-SumObj
          where temp-SumObj.obj-type = obj-list.obj-type
            and temp-SumObj.obj-code = obj-list.obj-code
          .
        run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
        if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
      end.
    end.
  end.


  if use-column1[11] = yes then do:
    for each temp-SumObj :
      assign
        temp-SumObj.val = 0
        temp-SumObj.sum = 0
      .
    end.

    do ii = 2 to 5 :
      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = ii
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        if ii = 5 then do:
          assign
            temp-SumObj.val = temp-SumObj.val - temp-value.qnty
            temp-SumObj.sum = temp-SumObj.sum - temp-value.sum
          .
        end.
        else do:
          assign
            temp-SumObj.val = temp-SumObj.val + temp-value.qnty
            temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
          .
        end.
      end.
    end.

    assign
      val-all = 0
      sum-all = 0
    .
    for each temp-SumObj :
      assign
        val-all = val-all + temp-SumObj.val
        sum-all = sum-all + temp-SumObj.sum
      .
    end.

    run SumGroup in this-procedure (val-all,sum-all) .
    if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
    for each obj-list :
      find first temp-SumObj
        where temp-SumObj.obj-type = obj-list.obj-type
          and temp-SumObj.obj-code = obj-list.obj-code
        .
      run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
      if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
    end.
  end.

  do ii = 6 to 8 :
    if use-column1[ii + 6] = yes then do: /* остатки */
      for each temp-SumObj :
        assign
          temp-SumObj.val = 0
          temp-SumObj.sum = 0
        .
      end.

      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = ii
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        assign
          temp-SumObj.val = temp-SumObj.val + temp-value.qnty
          temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
        .
      end.

      assign
        val-all = 0
        sum-all = 0
      .
      for each temp-SumObj :
        assign
          val-all = val-all + temp-SumObj.val
          sum-all = sum-all + temp-SumObj.sum
        .
      end.

      run SumGroup in this-procedure (val-all,sum-all) .
      if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
      for each obj-list :
        find first temp-SumObj
          where temp-SumObj.obj-type = obj-list.obj-type
            and temp-SumObj.obj-code = obj-list.obj-code
          .
        run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
        if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
      end.
    end.
  end.

  if use-column1[15] = yes then do: /* остатки */
    for each temp-month :
      for each temp-SumObj :
        assign
          temp-SumObj.val = 0
          temp-SumObj.sum = 0
        .
      end.

      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = temp-month.ind + 10
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        assign
          temp-SumObj.val = temp-SumObj.val + temp-value.qnty
          temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
        .
      end.

      assign
        val-all = 0
        sum-all = 0
      .
      for each temp-SumObj :
        assign
          val-all = val-all + temp-SumObj.val
          sum-all = sum-all + temp-SumObj.sum
        .
      end.

      run SumGroup in this-procedure (val-all,sum-all) .
      if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
      for each obj-list :
        find first temp-SumObj
          where temp-SumObj.obj-type = obj-list.obj-type
            and temp-SumObj.obj-code = obj-list.obj-code
          .
        run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
        if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
      end.
    end.
  end.


  do ii = 1 to 3 :
    if use-column1[ii + 15] = yes then do: /* остатки */
      for each temp-SumObj :
        assign
          temp-SumObj.val = 0
          temp-SumObj.sum = 0
        .
      end.
      case ii :
        when 1 then ind = 9 .
        when 2 then ind = 5 .
        when 3 then ind = 10 .
      end.

      for each temp-value
        where temp-value.artic     = temp-BenetTov.artic
          and temp-value.prod-type = temp-BenetTov.prod-type
          and temp-value.prod-code = temp-BenetTov.prod-code
          and temp-value.type      = ind
        :
        find first temp-SumObj
          where temp-SumObj.obj-type = temp-value.obj-type
            and temp-SumObj.obj-code = temp-value.obj-code
          .
        assign
          temp-SumObj.val = temp-SumObj.val + temp-value.qnty
          temp-SumObj.sum = temp-SumObj.sum + temp-value.sum
        .
      end.

      assign
        val-all = 0
        sum-all = 0
      .
      for each temp-SumObj :
        assign
          val-all = val-all + temp-SumObj.val
          sum-all = sum-all + temp-SumObj.sum
        .
      end.

      run SumGroup in this-procedure (val-all,sum-all) .
      if Itog = no then {&PutExcel}  excel-qnty2(val-all)  {&tabulation}  excel-sum2(sum-all)  {&tabulation} .
      for each obj-list :
        find first temp-SumObj
          where temp-SumObj.obj-type = obj-list.obj-type
            and temp-SumObj.obj-code = obj-list.obj-code
          .
        run SumGroup in this-procedure (temp-SumObj.val,temp-SumObj.sum) .
        if Itog = no then {&PutExcel}  excel-qnty2(temp-SumObj.val)  {&tabulation}  excel-sum2(temp-SumObj.sum)  {&tabulation} .
      end.
    end.
  end.

  if Itog = no then {&PutExcel}  {&new-line} .

/* $Workfile$ e n d */