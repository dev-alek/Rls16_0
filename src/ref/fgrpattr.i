/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами групп блюд

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/08/05
Author: Bakhtadze Natalya
Creation date: 08/08/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* Атрибуты */

/* ------------------------------------------------------------------- */
/* сюда добавлять новые параметры */
/* ------------------------------------------------------------------- */

/* и сюда добавлять новые параметры вот так */

&glob fbr-gds-grp-attr-list   '':u



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


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure fbr-grp-attr-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
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
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "Неизвестный атрибут группы блюд" + " " + p-code .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure fbr-grp-attr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :


      /* сюда добавлять новые параметры */
      otherwise do:
            undo, return error "Неизвестный атрибут группы блюд" + " " + p-code .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------
Процедура для определения значения атрибута группы и области, в которой задан атрибут
input:
    p-node-code - код группы
    p-code      - код атрибута
    p-host-code - код фирмы
    p-obj-type  - тип объекта
    p-obj-code  - код объекта
output:
    p-value     - значение атрибута
    p-type      - тип атрибута
*/
procedure fbr-grp-attr-value :
do
on error undo, return error
:
define input  parameter p-obj-type    as character  no-undo.      /* тип объекта  */
define input  parameter p-obj-code    as integer    no-undo.      /* код объекта  */
define input  parameter p-node-code   as integer    no-undo.      /* код группы   */
define input  parameter p-code        as character  no-undo.      /* код атрибута */
define output parameter p-value       as character  no-undo.      /* значение атрибута */
define output parameter p-type        as character  no-undo.      /* тип атрибута      */

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    define buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr.

    run fbr-grp-attr-name in this-procedure (
          input  p-code           /* p-code           */
        , output p-type           /* p-type           */
        , output v-format         /* p-format         */
        , output v-label          /* p-label          */
        , output v-user-can-edit  /* p-user-can-edit  */
        , output v-output-display /* p-output-display */
        , output v-other          /* p-other          */
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_fbr-gds-grp-attr no-lock     /* Ищем атрибут по объекту */
         where buf_fbr-gds-grp-attr.obj-type  = p-obj-type
           and buf_fbr-gds-grp-attr.obj-code  = p-obj-code
           and buf_fbr-gds-grp-attr.node-code = p-node-code
           and buf_fbr-gds-grp-attr.attr-code = p-code
    no-error .
    if available buf_fbr-gds-grp-attr
    then do:
        assign
            p-value = buf_fbr-gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
        p-value = (if p-type = {&type-log} then "no":U else "")
        .
    end.
end.
end procedure.
/*----------------------------------------------------
Процедура для заполнения значения атрибута группы
input:
    p-node-code - код группы товаров
    p-host-code - код фирмы
    p-obj-type  - объект
    p-obj-code  -
    p-code      - код атрибута
    p-value     - значение атрибута (текст)
*/
procedure fbr-grp-attr-write :
do
on error undo, return error
:
define input parameter p-obj-type   like ub.fbr-gds-grp-attr.obj-type            no-undo.
define input parameter p-obj-code   like ub.fbr-gds-grp-attr.obj-code            no-undo.
define input parameter p-node-code  like ub.fbr-gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.fbr-gds-grp-attr.attr-code      no-undo.
define input parameter p-value      like ub.fbr-gds-grp-attr.attr-value     no-undo.

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    define buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr .

    run fbr-grp-attr-name in this-procedure (
                      input  p-code           /* p-code           */
                    , output v-type           /* v-type           */
                    , output v-format         /* v-format         */
                    , output v-label          /* v-label          */
                    , output v-user-can-edit  /* v-user-can-edit  */
                    , output v-output-display /* v-output-display */
                    , output v-other          /* v-other          */
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_fbr-gds-grp-attr exclusive-lock
         where buf_fbr-gds-grp-attr.obj-type   = p-obj-type
           and buf_fbr-gds-grp-attr.obj-code   = p-obj-code
           and buf_fbr-gds-grp-attr.node-code  = p-node-code
           and buf_fbr-gds-grp-attr.attr-code  = p-code
    no-error.
    if not available buf_fbr-gds-grp-attr
    then do:
        create buf_fbr-gds-grp-attr.
        assign
        buf_fbr-gds-grp-attr.node-code  = p-node-code
        buf_fbr-gds-grp-attr.attr-code  = p-code
        buf_fbr-gds-grp-attr.obj-type   = p-obj-type
        buf_fbr-gds-grp-attr.obj-code   = p-obj-code
        buf_fbr-gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_fbr-gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
/*-----------------------------------------------------------------------------------------------------------------------
Процедура для удаления атрибута группы в заданной области
input:
    p-node-code - код группы товаров
    p-code      - код атрибута
    p-host-code - код фирмы
    p-obj-type  - тип объекта
    p-obj-code  - код объекта
    p-deleted   - no, если атрибута не было (нечего было удалять)
output:

*/
procedure fbr-grp-attr-delete :
do
on error undo, return error
:
define input parameter p-obj-type   like ub.fbr-gds-grp-attr.obj-type        no-undo.
define input parameter p-obj-code   like ub.fbr-gds-grp-attr.obj-code        no-undo.
define input parameter p-node-code  like ub.fbr-gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.fbr-gds-grp-attr.attr-code  no-undo.
define output parameter p-deleted   as logical                      no-undo.

    define buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr .

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    run fbr-grp-attr-name in this-procedure
    ( input  p-code           /* p-code           */
    , output v-type           /* p-type           */
    , output v-format         /* p-format         */
    , output v-label          /* p-label          */
    , output v-user-can-edit  /* p-user-can-edit  */
    , output v-output-display /* p-output-display */
    , output v-other          /* p-other          */
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_fbr-gds-grp-attr exclusive-lock
         where buf_fbr-gds-grp-attr.obj-type   = p-obj-type
           and buf_fbr-gds-grp-attr.obj-code   = p-obj-code
           and buf_fbr-gds-grp-attr.node-code  = p-node-code
           and buf_fbr-gds-grp-attr.attr-code  = p-code
    no-error.
    if not available buf_fbr-gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_fbr-gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.

procedure fbr-grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут группы блюд" + " " + p-code .
      end.
    end.
end.
end procedure.

/* $Workfile$ e n d */