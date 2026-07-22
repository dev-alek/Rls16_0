/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для атрибутов заказов и поставок ШАПКИ

Автор: Чернова Светлана Александровна
Дата создания: 11/27/08
Author: Svetlana Chernova
Creation date: 11/27/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */

/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-doc-code           {&type-char}
&glob format-orddocattr-cycle-doc-code         "x(16)"
&glob fillin_width-orddocattr-cycle-doc-code   20
&glob fillin_height-orddocattr-cycle-doc-code  1
&glob label-orddocattr-cycle-doc-code          "Номер заказа цикличного"
&glob tooltip-orddocattr-cycle-doc-code        "Номер заказа цикличного"
&glob user-can-edit-orddocattr-cycle-doc-code  false
&glob output-display-orddocattr-cycle-doc-code false
&glob other-orddocattr-cycle-doc-code          '':u
&glob news-orddocattr-cycle-doc-code           true
&glob sort-orddocattr-cycle-doc-code           10
&glob proc-orddocattr-cycle-doc-code           '':u
&glob func-orddocattr-cycle-doc-code           '':u

/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-done           {&type-char}
&glob format-orddocattr-cycle-done         "x(16)"
&glob fillin_width-orddocattr-cycle-done   20
&glob fillin_height-orddocattr-cycle-done  1
&glob label-orddocattr-cycle-done          "Заказ рассчитан"
&glob tooltip-orddocattr-cycle-done        "Заказ рассчитан"
&glob user-can-edit-orddocattr-cycle-done  false
&glob output-display-orddocattr-cycle-done false
&glob other-orddocattr-cycle-done          '':u
&glob news-orddocattr-cycle-done           true
&glob sort-orddocattr-cycle-done           10
&glob proc-orddocattr-cycle-done           '':u
&glob func-orddocattr-cycle-done           '':u


/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-day           {&type-int}
&glob format-orddocattr-cycle-day         ">>>>>>9"
&glob fillin_width-orddocattr-cycle-day   20
&glob fillin_height-orddocattr-cycle-day  1
&glob label-orddocattr-cycle-day          "период цикличности"
&glob tooltip-orddocattr-cycle-day        "период цикличности"
&glob user-can-edit-orddocattr-cycle-day  false
&glob output-display-orddocattr-cycle-day false
&glob other-orddocattr-cycle-day          '':u
&glob news-orddocattr-cycle-day           true
&glob sort-orddocattr-cycle-day           10
&glob proc-orddocattr-cycle-day           '':u
&glob func-orddocattr-cycle-day           '':u


/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-contract-code           {&type-char}
&glob format-orddocattr-cycle-contract-code         "x(16)"
&glob fillin_width-orddocattr-cycle-contract-code   20
&glob fillin_height-orddocattr-cycle-contract-code  1
&glob label-orddocattr-cycle-contract-code          "договор"
&glob tooltip-orddocattr-cycle-contract-code        "договор"
&glob user-can-edit-orddocattr-cycle-contract-code  false
&glob output-display-orddocattr-cycle-contract-code false
&glob other-orddocattr-cycle-contract-code          '':u
&glob news-orddocattr-cycle-contract-code           true
&glob sort-orddocattr-cycle-contract-code           10
&glob proc-orddocattr-cycle-contract-code           '':u
&glob func-orddocattr-cycle-contract-code           '':u

/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-ship-date           {&type-date}
&glob format-orddocattr-cycle-ship-date         "99/99/9999"
&glob fillin_width-orddocattr-cycle-ship-date   20
&glob fillin_height-orddocattr-cycle-ship-date  1
&glob label-orddocattr-cycle-ship-date          "дата доставки"
&glob tooltip-orddocattr-cycle-ship-date        "дата доставки"
&glob user-can-edit-orddocattr-cycle-ship-date  false
&glob output-display-orddocattr-cycle-ship-date false
&glob other-orddocattr-cycle-ship-date          '':u
&glob news-orddocattr-cycle-ship-date           true
&glob sort-orddocattr-cycle-ship-date           10
&glob proc-orddocattr-cycle-ship-date           '':u
&glob func-orddocattr-cycle-ship-date           '':u

/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-ship-time           {&type-int}
&glob format-orddocattr-cycle-ship-time         "x(16)"
&glob fillin_width-orddocattr-cycle-ship-time   20
&glob fillin_height-orddocattr-cycle-ship-time  1
&glob label-orddocattr-cycle-ship-time          "время доставки"
&glob tooltip-orddocattr-cycle-ship-time        "время доставки"
&glob user-can-edit-orddocattr-cycle-ship-time  false
&glob output-display-orddocattr-cycle-ship-time false
&glob other-orddocattr-cycle-ship-time          '':u
&glob news-orddocattr-cycle-ship-time           true
&glob sort-orddocattr-cycle-ship-time           10
&glob proc-orddocattr-cycle-ship-time           '':u
&glob func-orddocattr-cycle-ship-time           '':u

/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-date1           {&type-date}
&glob format-orddocattr-cycle-date1         "99/99/9999"
&glob fillin_width-orddocattr-cycle-date1   20
&glob fillin_height-orddocattr-cycle-date1  1
&glob label-orddocattr-cycle-date1          "период продаж"
&glob tooltip-orddocattr-cycle-date1        "период продаж"
&glob user-can-edit-orddocattr-cycle-date1  false
&glob output-display-orddocattr-cycle-date1 false
&glob other-orddocattr-cycle-date1          '':u
&glob news-orddocattr-cycle-date1           true
&glob sort-orddocattr-cycle-date1           10
&glob proc-orddocattr-cycle-date1           '':u
&glob func-orddocattr-cycle-date1           '':u

/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-date2           {&type-date}
&glob format-orddocattr-cycle-date2         "99/99/9999"
&glob fillin_width-orddocattr-cycle-date2   20
&glob fillin_height-orddocattr-cycle-date2  1
&glob label-orddocattr-cycle-date2          "период продаж"
&glob tooltip-orddocattr-cycle-date2        "период продаж"
&glob user-can-edit-orddocattr-cycle-date2  false
&glob output-display-orddocattr-cycle-date2 false
&glob other-orddocattr-cycle-date2          '':u
&glob news-orddocattr-cycle-date2           true
&glob sort-orddocattr-cycle-date2           10
&glob proc-orddocattr-cycle-date2           '':u
&glob func-orddocattr-cycle-date2           '':u

&glob type-orddocattr-cycle-doc-date           {&type-date}
&glob format-orddocattr-cycle-doc-date         "99/99/9999"
&glob fillin_width-orddocattr-cycle-doc-date   20
&glob fillin_height-orddocattr-cycle-doc-date  1
&glob label-orddocattr-cycle-doc-date          "дата заказа"
&glob tooltip-orddocattr-cycle-doc-date        "дата док заказа"
&glob user-can-edit-orddocattr-cycle-doc-date  false
&glob output-display-orddocattr-cycle-doc-date false
&glob other-orddocattr-cycle-doc-date          '':u
&glob news-orddocattr-cycle-doc-date           true
&glob sort-orddocattr-cycle-doc-date           10
&glob proc-orddocattr-cycle-doc-date           '':u
&glob func-orddocattr-cycle-doc-date           '':u

/* Сохранение цикличного заказа */
&glob type-orddocattr-cycle-exch-code           {&type-char}
&glob format-orddocattr-cycle-exch-code         "x(16)"
&glob fillin_width-orddocattr-cycle-exch-code   20
&glob fillin_height-orddocattr-cycle-exch-code  1
&glob label-orddocattr-cycle-exch-code          "Валюта Заказа"
&glob tooltip-orddocattr-cycle-exch-code        "Валюта Заказа"
&glob user-can-edit-orddocattr-cycle-exch-code  false
&glob output-display-orddocattr-cycle-exch-code false
&glob other-orddocattr-cycle-exch-code          '':u
&glob news-orddocattr-cycle-exch-code           true
&glob sort-orddocattr-cycle-exch-code           10
&glob proc-orddocattr-cycle-exch-code           '':u
&glob func-orddocattr-cycle-exch-code           '':u

&glob type-orddocattr-cycle-exch-rate           {&type-char}
&glob format-orddocattr-cycle-exch-rate         "x(16)"
&glob fillin_width-orddocattr-cycle-exch-rate   20
&glob fillin_height-orddocattr-cycle-exch-rate  1
&glob label-orddocattr-cycle-exch-rate          "Валюта Заказа"
&glob tooltip-orddocattr-cycle-exch-rate        "Валюта Заказа"
&glob user-can-edit-orddocattr-cycle-exch-rate  false
&glob output-display-orddocattr-cycle-exch-rate false
&glob other-orddocattr-cycle-exch-rate          '':u
&glob news-orddocattr-cycle-exch-rate           true
&glob sort-orddocattr-cycle-exch-rate           10
&glob proc-orddocattr-cycle-exch-rate           '':u
&glob func-orddocattr-cycle-exch-rate           '':u

&glob type-orddocattr-cycle-exch-scale           {&type-char}
&glob format-orddocattr-cycle-exch-scale         "x(16)"
&glob fillin_width-orddocattr-cycle-exch-scale   20
&glob fillin_height-orddocattr-cycle-exch-scale  1
&glob label-orddocattr-cycle-exch-scale          "Валюта Заказа"
&glob tooltip-orddocattr-cycle-exch-scale        "Валюта Заказа"
&glob user-can-edit-orddocattr-cycle-exch-scale  false
&glob output-display-orddocattr-cycle-exch-scale false
&glob other-orddocattr-cycle-exch-scale          '':u
&glob news-orddocattr-cycle-exch-scale           true
&glob sort-orddocattr-cycle-exch-scale           10
&glob proc-orddocattr-cycle-exch-scale           '':u
&glob func-orddocattr-cycle-exch-scale           '':u

&glob type-orddocattr-cycle-base-rate           {&type-char}
&glob format-orddocattr-cycle-base-rate         "x(16)"
&glob fillin_width-orddocattr-cycle-base-rate   20
&glob fillin_height-orddocattr-cycle-base-rate  1
&glob label-orddocattr-cycle-base-rate          "Валюта Заказа"
&glob tooltip-orddocattr-cycle-base-rate        "Валюта Заказа"
&glob user-can-edit-orddocattr-cycle-base-rate  false
&glob output-display-orddocattr-cycle-base-rate false
&glob other-orddocattr-cycle-base-rate          '':u
&glob news-orddocattr-cycle-base-rate           true
&glob sort-orddocattr-cycle-base-rate           10
&glob proc-orddocattr-cycle-base-rate           '':u
&glob func-orddocattr-cycle-base-rate           '':u

&glob type-orddocattr-cycle-base-scale           {&type-char}
&glob format-orddocattr-cycle-base-scale         "x(16)"
&glob fillin_width-orddocattr-cycle-base-scale   20
&glob fillin_height-orddocattr-cycle-base-scale  1
&glob label-orddocattr-cycle-base-scale          "Валюта Заказа"
&glob tooltip-orddocattr-cycle-base-scale        "Валюта Заказа"
&glob user-can-edit-orddocattr-cycle-base-scale  false
&glob output-display-orddocattr-cycle-base-scale false
&glob other-orddocattr-cycle-base-scale          '':u
&glob news-orddocattr-cycle-base-scale           true
&glob sort-orddocattr-cycle-base-scale           10
&glob proc-orddocattr-cycle-base-scale           '':u
&glob func-orddocattr-cycle-base-scale           '':u

&glob type-orddocattr-ora-exp-seq-num            {&type-int}
&glob format-orddocattr-ora-exp-seq-num          "999999999"
&glob fillin_width-orddocattr-ora-exp-seq-num    20
&glob fillin_height-orddocattr-ora-exp-seq-num   1
&glob label-orddocattr-ora-exp-seq-num           "Номер выгрузки в Oracle Retail"
&glob tooltip-orddocattr-ora-exp-seq-num         "Номер выгрузки в Oracle Retail"
&glob user-can-edit-orddocattr-ora-exp-seq-num   false
&glob output-display-orddocattr-ora-exp-seq-num  false
&glob other-orddocattr-ora-exp-seq-num           '':u
&glob news-orddocattr-ora-exp-seq-num            true
&glob sort-orddocattr-ora-exp-seq-num            100
&glob proc-orddocattr-ora-exp-seq-num            '':u
&glob func-orddocattr-ora-exp-seq-num            '':u



/* ------------------------------------------------------------------- */
procedure orddocattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input  parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-doc-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    run orddocattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if avail buf_ord-doc-attr then do:
      assign
        p-value =  buf_ord-doc-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.

procedure orddocattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-doc-attr.attr-value no-undo .

    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    run orddocattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if not available buf_ord-doc-attr then do:
      create buf_ord-doc-attr .
      assign
        buf_ord-doc-attr.doc-code  = p-doc-code
        buf_ord-doc-attr.attr-code = p-code
      .
    end.
    assign
      buf_ord-doc-attr.attr-value = p-value
    .
end.
end procedure.

procedure orddocattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_ord-doc-attr for ub.ord-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    run orddocattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error .
    if  available buf_ord-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.

procedure orddocattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.ord-doc-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_ord-doc-attr for ub.ord-doc-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    define variable v-other          as character no-undo .
    run orddocattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-doc-attr exclusive-lock
      where buf_ord-doc-attr.doc-code  = p-doc-code
        and buf_ord-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-doc-attr.
      p-deleted = yes.
    end.
  end.
end procedure.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label          = ~{&label-~{&attr-code~}~} ~
    p-type           = ~{&type-~{&attr-code~}~}  ~
    p-format         = ~{&format-~{&attr-code~}~} ~
    p-fillin_width   = ~{&fillin_width-~{&attr-code~}~} ~
    p-fillin_height  = ~{&fillin_height-~{&attr-code~}~} ~
    p-label          = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-sort           = ~{&sort-~{&attr-code~}~} ~
    p-proc           = ~{&proc-~{&attr-code~}~} ~
    p-func           = ~{&func-~{&attr-code~}~} ~
    p-other          = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

procedure orddocattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo . /* код атрибута    */
    define output parameter p-type           as character no-undo . /* тип атрибута    */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-fillin_width   as integer   no-undo . /* ширина          */
    define output parameter p-fillin_height  as integer   no-undo . /* высота          */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */

    case p-code :
      &scop attr-code orddocattr-cycle-doc-code
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-day
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-done
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-exch-code
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-exch-rate
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-exch-scale
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-base-rate
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-base-scale
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-contract-code
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-ship-date
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-ship-time
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-date1
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-date2
      {&attr-temp-full-code}
      &scop attr-code orddocattr-cycle-doc-date
      {&attr-temp-full-code}
      &scop attr-code orddocattr-ora-exp-seq-num
      {&attr-temp-full-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.