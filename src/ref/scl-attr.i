/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека работы с атрибутами весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/11/04
Author: Bakhtadze Natalya
Creation date: 06/11/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */


/* Веса тары  для TIGER*/
&scop bef-scl-attr-tare-weight tare-weight
&glob scl-attr-tare-weight '{&bef-scl-attr-tare-weight}':U
&scop type-scl-attr-tare-weight {&type-char}
&scop format-scl-attr-tare-weight "X(32)"
&scop label-scl-attr-tare-weight "Веса и коды тары"
&scop tooltip-scl-attr-tare-weight "Веса и коды тары"
&scop user-can-edit-scl-attr-tare-weight yes
&scop output-display-scl-attr-tare-weight true
&scop other-scl-attr-tare-weight 'scl=TIGER,MIRA,TIGER2,TIGER-SPCT2/spr=scl-attr-tare-weight':u
&scop news-scl-attr-tare-weight yes
&scop hist-scl-attr-tare-weight yes


/* сюда добавлять новые параметры */

&glob scl-attr-list '{&bef-scl-attr-tare-weight}~
':u

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

&scop attr-hist-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-hist = ~{&hist-~{&attr-code~}~}. ~
  end.


{ gbl/cur-time.i }
procedure scl-attr-code :

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
      &scop attr-code scl-attr-tare-weight
      {&attr-temp-full-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут весов" + " " + p-code .
      end.
    end.
  end.
end procedure.

procedure scl-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code scl-attr-tare-weight
      {&attr-temp-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут весов" + " " + p-code .
      end.
    end.
  end.

end procedure.


procedure scl-attr-value :

  do
  on error undo, return error
  :
    define input  parameter p-db-num   like ub.scales-attr.db-num        no-undo .
    define input  parameter p-scales-num like ub.scales-attr.scales-num      no-undo .
    define input  parameter p-code     like ub.scales-attr.attr-code      no-undo .
    define output parameter p-value    like ub.scales-attr.attr-value    no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_scales-attr for ub.scales-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run scl-attr-code in this-procedure
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

    find first buf_scales-attr no-lock
      where buf_scales-attr.db-num    = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if avail buf_scales-attr then do:
      assign
        p-value =  buf_scales-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure scl-attr-write :

  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define input parameter p-value    like ub.scales-attr.attr-value no-undo .

    define buffer buf_scales-attr for ub.scales-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run scl-attr-code in this-procedure
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

    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if not available buf_scales-attr then do:
      create buf_scales-attr .
      assign
        buf_scales-attr.db-num    = p-db-num
        buf_scales-attr.scales-num  = p-scales-num
        buf_scales-attr.attr-code = p-code
      .
    end.
    assign
      buf_scales-attr.attr-value = p-value
    .
    release buf_scales-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure scl-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_scales-attr for ub.scales-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run scl-attr-code in this-procedure
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

    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .

    if  available buf_scales-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure scl-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .

    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_scales-attr for ub.scales-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run scl-attr-code in this-procedure
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
    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_scales-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_scales-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure scl-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code scl-attr-tare-weight
      {&attr-news-code}
      /* сюда добавлять новые параметры */

      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.


procedure scl-attr-hist :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-hist           as logical   no-undo . /* ходит в историю */

    case p-code :
      &scop attr-code scl-attr-tare-weight
      {&attr-hist-code}
      /* сюда добавлять новые параметры */


      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.

&if "{1}" = "interface" &then

procedure scl-attr-tare-weight:
define input parameter p-db-num like ub.scales.db-num no-undo .
define input parameter p-scales-num like ub.scales.scales-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .

  do
  on error undo, return error
  :
    assign
    v-value = p-value.
    run ref/tiger-w.w (
                    input p-db-num
                   ,input p-scales-num
                   ,input-output v-value).
    if p-value <> v-value then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* gds-obj-std-disc */


&endif


/* $Workfile$ e n d */