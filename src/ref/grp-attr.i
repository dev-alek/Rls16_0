/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами группы товаров.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(grp-attr_i) = 0 &then

&glob grp-attr_i


/* Атрибуты */
/*--- Набор --------------------------------------- */
&scop bef-attr-gds-grp-nabor-h gds-grp-nabor
&glob attr-gds-grp-nabor-h '{&bef-attr-gds-grp-nabor-h}':U
&glob type-attr-gds-grp-nabor-h {&type-log}
&glob format-attr-gds-grp-nabor-h  "yes/no"
&glob label-attr-gds-grp-nabor-h   "Набор"
&glob tooltip-attr-gds-grp-nabor-h   "Набор - не товарные позиции"
&glob user-can-edit-attr-gds-grp-nabor-h  true
&glob output-display-attr-gds-grp-nabor-h  true
&glob other-attr-gds-grp-nabor-h  ""
&glob news-attr-gds-grp-nabor-h true

/* ------------------------------------------------------------------- */
/* сюда добавлять новые параметры */
/* ------------------------------------------------------------------- */

/* и сюда добавлять новые параметры вот так */

&glob gds-grp-attr-list   '{&bef-attr-gds-grp-nabor-h}':u



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
procedure grp-attr-name :
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
      &scop attr-code attr-gds-grp-nabor-h
      {&attr-temp-full-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure grp-attr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :

      &scop attr-code attr-gds-grp-nabor-h
      {&attr-temp-code}

      /* сюда добавлять новые параметры */
      otherwise do:
            undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
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
procedure grp-attr-value :
do
on error undo, return error
:
define input  parameter p-node-code   as integer    no-undo.      /* код группы   */
define input  parameter p-code        as character  no-undo.      /* код атрибута */
define input  parameter p-host-code   as integer    no-undo.      /* код фирмы    */
define input  parameter p-obj-type    as character  no-undo.      /* тип объекта  */
define input  parameter p-obj-code    as integer    no-undo.      /* код объекта  */
define output parameter p-value       as character  no-undo.      /* значение атрибута */
define output parameter p-type        as character  no-undo.      /* тип атрибута      */

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    define buffer buf_gds-grp-attr for ub.gds-grp-attr.

    run grp-attr-name in this-procedure (
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
    find first buf_gds-grp-attr no-lock     /* Ищем атрибут по объекту */
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-code
           and buf_gds-grp-attr.host-code = p-host-code
           and buf_gds-grp-attr.obj-type  = p-obj-type
           and buf_gds-grp-attr.obj-code  = p-obj-code
    no-error .
    if available buf_gds-grp-attr
    then do:
        assign
            p-value = buf_gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
            p-value = if p-type = {&type-log} then "no":U else ""
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
procedure grp-attr-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-value      like ub.gds-grp-attr.attr-value     no-undo.

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    define buffer buf_gds-grp-attr for ub.gds-grp-attr .

    run grp-attr-name in this-procedure (
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
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        create buf_gds-grp-attr.
        assign
                buf_gds-grp-attr.node-code  = p-node-code
                buf_gds-grp-attr.attr-code  = p-code
                buf_gds-grp-attr.host-code  = p-host-code
                buf_gds-grp-attr.obj-type   = p-obj-type
                buf_gds-grp-attr.obj-code   = p-obj-code
                buf_gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_gds-grp-attr.attr-value = p-value
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
procedure grp-attr-delete :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code  no-undo.
define input parameter p-host-code  as integer                      no-undo.
define input parameter p-obj-type   like ub.clients.obj-type        no-undo.
define input parameter p-obj-code   like ub.clients.obj-code        no-undo.
define output parameter p-deleted   as logical                      no-undo.

    define buffer buf_gds-grp-attr for ub.gds-grp-attr .

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    run grp-attr-name in this-procedure
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
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.

procedure grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :

      &scop attr-code attr-gds-grp-nabor-h
      {&attr-news-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут товара на фирме" + " " + p-code .
      end.
    end.
end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------
Процедура для определения значения некоего атриубат для группы
на объекте.
input:
    p-node-code - код группы
    p-obj-type  - тип объекта
    p-obj-code  - код объекта
    p-attr-code - код атрибута
output:
    p-attr-value - значение атрибута
    p-range     - область действия наценки ( 1 - глобально, 2 - по фирме p-host-code, 3 - по объекту )
    p-exists    - наценка найдена/не найдена
*/


procedure grp-attr-obj-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-attr-code as character    no-undo .
define output parameter p-attr-value     as character   no-undo.
define output parameter p-range     as integer      no-undo.
define output parameter p-exists    as logical      no-undo.

define variable v-host-code as integer      no-undo.

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code no-error }
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.

define buffer buf_gds-grp-attr      for ub.gds-grp-attr.
find first buf_gds-grp-attr no-lock
     where buf_gds-grp-attr.node-code = p-node-code
       and buf_gds-grp-attr.attr-code = p-attr-code
       and buf_gds-grp-attr.host-code = v-host-code
       and buf_gds-grp-attr.obj-type  = p-obj-type
       and buf_gds-grp-attr.obj-code  = p-obj-code
no-error .
if not available buf_gds-grp-attr
then do:
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-attr-code
           and buf_gds-grp-attr.host-code = v-host-code
           and buf_gds-grp-attr.obj-type  = ""
           and buf_gds-grp-attr.obj-code  = 0
    no-error .
    if not available buf_gds-grp-attr
    then do:
        find first buf_gds-grp-attr no-lock
            where buf_gds-grp-attr.node-code = p-node-code
            and buf_gds-grp-attr.attr-code = p-attr-code
            and buf_gds-grp-attr.host-code = 0
            and buf_gds-grp-attr.obj-type  = ""
            and buf_gds-grp-attr.obj-code  = 0
        no-error .
        if not available buf_gds-grp-attr
        then do:
            assign
                p-exists = no
            .
        end.
        else do:        /* Найдена запись для глобального значения */
            assign
                p-exists = yes
                p-range  = 1
            .
        end.
    end.
    else do:        /* Найдена запись по фирме */
        assign
            p-exists = yes
            p-range  = 2
        .
    end.        /* available buf_gds-grp-attr */
end.        /* not available buf_gds-grp-attr  */
else do:        /* Найдена запись по объекту */
    assign
        p-exists = yes
        p-range  = 3
    .
end.        /* available buf_gds-grp-attr */
if available buf_gds-grp-attr
then do:
  assign
  p-attr-value = buf_gds-grp-attr.attr-value
  .
end.
end.
end procedure.


procedure ver-gds-grp-nabor :
do
on error undo, return error return-value
:
/* Проверка по коду товара набор он или нет */

define input  parameter p-gds-code as integer   no-undo .  /* goods.gds-code */
define output parameter p-nabor as logical   no-undo .     /* no- не набор   */
define buffer buf_goods for ub.goods.
p-nabor = false .

find first  buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error .

define variable v-value       as character  no-undo.      /* значение атрибута */
define variable v-type        as character  no-undo.      /* тип атрибута      */
  run grp-attr-value (
     input   buf_goods.grp-code              /* код группы   */
    ,input   {&attr-gds-grp-nabor-h}         /* код атрибута */
    ,input   0                               /* код фирмы    */
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .

  if v-value = "yes" then p-nabor = true  .
end.
end procedure. /* ver-gds-grp-nabor */

&endif

/* $Workfile$ e n d */