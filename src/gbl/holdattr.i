/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами фирмы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */

&scop bef-hold-attr-begin-date begin-date
&glob hold-attr-begin-date '{&bef-hold-attr-begin-date}':U
&scop type-hold-attr-begin-date {&type-date}
&scop format-hold-attr-begin-date "99/99/9999"
&scop label-hold-attr-begin-date "Дата начала межфирменного архива"
&scop tooltip-hold-attr-begin-date "Дата начала межфирменного архива"
&scop user-can-edit-hold-attr-begin-date false
&scop output-display-hold-attr-begin-date true
&scop other-hold-attr-begin-date '':u
&scop news-hold-attr-begin-date no


&scop bef-hold-attr-is-calc is-calc
&glob hold-attr-is-calc '{&bef-hold-attr-is-calc}':U
&scop type-hold-attr-is-calc {&type-log}
&scop format-hold-attr-is-calc "+/-"
&scop label-hold-attr-is-calc "Произв.расчет арх."
&scop tooltip-hold-attr-is-calc "Производится расчет межфирменного архива"
&scop user-can-edit-hold-attr-is-calc false
&scop output-display-hold-attr-is-calc true
&scop other-hold-attr-is-calc '':u
&scop news-hold-attr-is-calc no


/* сюда добавлять новые параметры */

&glob hold-attr-list '{&bef-hold-attr-begin-date},{&bef-hold-attr-is-calc}':u


/* ------------------------------------------------------------------- */
&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.



procedure holdattr-code :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */

    case p-code :
      &scop attr-code hold-attr-begin-date
      {&attr-temp-full-code}
      &scop attr-code hold-attr-is-calc
      {&attr-temp-full-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.

procedure holdattr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code hold-attr-begin-date
      {&attr-temp-code}
      &scop attr-code hold-attr-is-calc
      {&attr-temp-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.

end procedure.


procedure holdattr-value :

  do
  on error undo, return error
  :
    define input  parameter p-cat-code  like ub.hold-attr.cat-code     no-undo .
    define input  parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define output parameter p-value     like ub.hold-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .

    define buffer buf_hold-attr for ub.hold-attr .

    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run holdattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_hold-attr no-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if avail buf_hold-attr then do:
      assign
        p-value =  buf_hold-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure holdattr-write :

  do
  on error undo, return error
  :
    define input parameter p-cat-code    like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define input parameter p-value     like ub.hold-attr.attr-value no-undo .

    define buffer buf_hold-attr for ub.hold-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run holdattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_hold-attr exclusive-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if not available buf_hold-attr then do:
      create buf_hold-attr .
      assign
        buf_hold-attr.cat-code    = p-cat-code
        buf_hold-attr.attr-code = p-code
      .
    end.
    assign
      buf_hold-attr.attr-value = p-value
    .
  end.

end procedure.


procedure holdattr-exist :

  do
  on error undo, return error
  :
    define input parameter p-cat-code    like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code      like ub.hold-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .

    define buffer buf_hold-attr for ub.hold-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run holdattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_hold-attr no-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error .
    if  available buf_hold-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.



procedure holdattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cat-code   like ub.hold-attr.cat-code     no-undo .
    define input parameter p-code     like ub.hold-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_hold-attr for ub.hold-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run holdattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_hold-attr exclusive-lock
      where buf_hold-attr.cat-code    = p-cat-code
        and buf_hold-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_hold-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_hold-attr.
      p-deleted = yes.
    end.
  end.

end procedure.

procedure holdattr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code hold-attr-begin-date
      {&attr-news-code}
      &scop attr-code hold-attr-is-calc
      {&attr-news-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут межфирменного архива" + " " + p-code .
      end.
    end.
  end.
end procedure.

/* $Workfile$ e n d */