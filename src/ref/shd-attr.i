/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами строки расписания.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


/* Атрибуты */
/*--- Строка параметров --------------------------------------- */
&scop bef-attr-schedule-param-list-h schedule-param-list
&glob attr-schedule-param-list-h '{&bef-attr-schedule-param-list-h}':U
&glob type-attr-schedule-param-list-h {&type-char}
&glob format-attr-schedule-param-list-h  "X(30)"
&glob label-attr-schedule-param-list-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-param-list-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-param-list-h  true
&glob output-display-attr-schedule-param-list-h  true
&glob other-attr-schedule-param-list-h  ""
&glob news-attr-schedule-param-list-h false
/*--- Список объектов --------------------------------------- */
&scop bef-attr-schedule-obj-list-h schedule-obj-list
&glob attr-schedule-obj-list-h '{&bef-attr-schedule-obj-list-h}':U
&glob type-attr-schedule-obj-list-h {&type-char}
&glob format-attr-schedule-obj-list-h  "X(30)"
&glob label-attr-schedule-obj-list-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-obj-list-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-obj-list-h  true
&glob output-display-attr-schedule-obj-list-h  true
&glob other-attr-schedule-obj-list-h  ""
&glob news-attr-schedule-obj-list-h false
/*--- Список клиентов --------------------------------------- */
&scop bef-attr-schedule-oss-list-h schedule-oss-list
&glob attr-schedule-oss-list-h '{&bef-attr-schedule-oss-list-h}':U
&glob type-attr-schedule-oss-list-h {&type-char}
&glob format-attr-schedule-oss-list-h  "X(30)"
&glob label-attr-schedule-oss-list-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-oss-list-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-oss-list-h  true
&glob output-display-attr-schedule-oss-list-h  true
&glob other-attr-schedule-oss-list-h  ""
&glob news-attr-schedule-oss-list-h false
/*--- Список товаров --------------------------------------- */
&scop bef-attr-schedule-gds-list-h schedule-gds-list
&glob attr-schedule-gds-list-h '{&bef-attr-schedule-gds-list-h}':U
&glob type-attr-schedule-gds-list-h {&type-char}
&glob format-attr-schedule-gds-list-h  "X(30)"
&glob label-attr-schedule-gds-list-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-gds-list-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-gds-list-h  true
&glob output-display-attr-schedule-gds-list-h  true
&glob other-attr-schedule-gds-list-h  ""
&glob news-attr-schedule-gds-list-h false
/*--- Список типов документов --------------------------------------- */
&scop bef-attr-schedule-doc-type-list-h schedule-doc-type-list
&glob attr-schedule-doc-type-list-h '{&bef-attr-schedule-doc-type-list-h}':U
&glob type-attr-schedule-doc-type-list-h {&type-char}
&glob format-attr-schedule-doc-type-list-h  "X(30)"
&glob label-attr-schedule-doc-type-list-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-doc-type-list-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-doc-type-list-h  true
&glob output-display-attr-schedule-doc-type-list-h  true
&glob other-attr-schedule-doc-type-list-h  ""
&glob news-attr-schedule-doc-type-list-h false
/*--- Диапазон дат --------------------------------------- */
&scop bef-attr-schedule-date-list-h schedule-date-list
&glob attr-schedule-date-list-h '{&bef-attr-schedule-date-list-h}':U
&glob type-attr-schedule-date-list-h {&type-char}
&glob format-attr-schedule-date-list-h  "X(30)"
&glob label-attr-schedule-date-list-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-date-list-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-date-list-h  true
&glob output-display-attr-schedule-date-list-h  true
&glob other-attr-schedule-date-list-h  ""
&glob news-attr-schedule-date-list-h false
/*--- Фильтры --------------------------------------- */
&scop bef-attr-schedule-filter-h schedule-filter
&glob attr-schedule-filter-h '{&bef-attr-schedule-filter-h}':U
&glob type-attr-schedule-filter-h {&type-char}
&glob format-attr-schedule-filter-h  "X(30)"
&glob label-attr-schedule-filter-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-filter-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-filter-h  true
&glob output-display-attr-schedule-filter-h  true
&glob other-attr-schedule-filter-h  ""
&glob news-attr-schedule-filter-h false

/*--- Фильтры 2--------------------------------------- */
&scop bef-attr-schedule-filter-2-h schedule-filter-2
&glob attr-schedule-filter-2-h '{&bef-attr-schedule-filter-2-h}':U
&glob type-attr-schedule-filter-2-h {&type-char}
&glob format-attr-schedule-filter-2-h  "X(30)"
&glob label-attr-schedule-filter-2-h   "Параметры строки расписания"
&glob tooltip-attr-schedule-filter-2-h   "Параметры строки расписания"
&glob user-can-edit-attr-schedule-filter-2-h  true
&glob output-display-attr-schedule-filter-2-h  true
&glob other-attr-schedule-filter-2-h  ""
&glob news-attr-schedule-filter-2-h false

/*--- Идентификатор произвольной задачи--------------- */
&scop bef-attr-schd-free-id schd-free-id
&glob attr-schd-free-id '{&bef-attr-schd-free-id}':U
&glob type-attr-schd-free-id {&type-char}
&glob format-attr-schd-free-id  "X(30)"
&glob label-attr-schd-free-id   "Идентификатор произвольной задачи"
&glob tooltip-attr-schd-free-id   "Идентификатор произвольной задачи"
&glob user-can-edit-attr-schd-free-id  false
&glob output-display-attr-schd-free-id  false
&glob other-attr-schd-free-id  ""
&glob news-attr-schd-free-id false
/*это составной атрибут -
attr-code = {&attr-schd-free-id} + {&delim-par} + [идентификатор задачи]
attr-value = [Название задачи] + {&delim-par} +
             [имя процедуры запускаемой в l-i-файле] + {&delim-par} +
             [имя процедуры редактирования параметров]  + {&delim-par} +
             [имя конфигурационного параметра проверяемого при вызове] + {&delim-par} +
             [запускается в ГБД] + {&delim-par} +
             [запускается в УБД] + {&delim-par} +
             [другая информация]
идентификатор вынесен в attr-code ДЛЯ ТОГО ЧТОБЫ ЕГО МОЖНО БЫЛО НАЙТИ ПО ИНДЕКСУ
соответствия идентификатор-процедура run-процедура параметров и т.д. лежат в файле
shd-free.d в формате dump progress
ПОНЯТНО! ЧТО ДЛЯ ОДНОГО task НЕ МОЖЕТ БЫТЬ БОЛЕЕ ОДНОГО АТРИБУТА ТАКОГО ТИПА!!!
поэтому при записи такого атрибута будем лочить exclusive само schedule
*/

define temp-table temp-schedule-free no-undo
field free-id as character
field free-task-name as character
field proc-run-name as character
field proc-param-edit-name as character
field conf-param as character
field is-gbd as logical
field is-ubd as logical
field enable-concurrent-0 as logical
field enable-concurrent-db as logical
field other-info as character
field enc-key as character
field is-rum as logical
index pi is unique primary
free-id.
/*!!!!! при изменении опрделения данной временной таблицы надо поправить schedule-attr-get-free-props  */


/* ------------------------------------------------------------------- */
/* сюда добавлять новые параметры */
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


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure schedule-attr-name :
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
    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-code :
      &scop attr-code attr-schedule-param-list-h
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-obj-list-h
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-oss-list-h
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-gds-list-h
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-doc-type-list-h
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-date-list-h
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-filter-h
      {&attr-temp-full-code}
      &scop attr-code attr-schedule-filter-2-h
      {&attr-temp-full-code}
      &scop attr-code attr-schd-free-id
      {&attr-temp-full-code}

      /* сюда добавлять новые параметры */
      otherwise do:

        undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure schedule-attr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-code :
      &scop attr-code attr-schedule-param-list-h
      {&attr-temp-code}
      &scop attr-code attr-schedule-obj-list-h
      {&attr-temp-code}
      &scop attr-code attr-schedule-oss-list-h
      {&attr-temp-code}
      &scop attr-code attr-schedule-gds-list-h
      {&attr-temp-code}
      &scop attr-code attr-schedule-doc-type-list-h
      {&attr-temp-code}
      &scop attr-code attr-schedule-date-list-h
      {&attr-temp-code}
      &scop attr-code attr-schedule-filter-h
      {&attr-temp-code}
      &scop attr-code attr-schedule-filter-2-h
      {&attr-temp-code}
      &scop attr-code attr-schd-free-id
      {&attr-temp-code}

      /* сюда добавлять новые параметры */
      otherwise do:
            undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------
Процедура для определения значения атрибута группы и области, в которой задан атрибут
input:
    p-node-code - код группы
    p-code      - код атрибута
output:
    p-value     - значение атрибута
    p-type      - тип атрибута
*/
procedure schedule-attr-value :
do
on error undo, return error return-value
:
define input parameter  p-cre-db-num as integer    no-undo.      /* PI строки расписания */
define input parameter  p-task-type  as character  no-undo.
define input parameter  p-task-num   as integer    no-undo.
define input parameter  p-code       as character  no-undo.      /* код атрибута */
define output parameter p-value      as character  no-undo.      /* значение атрибута */
define output parameter p-type       as character  no-undo.      /* тип атрибута      */

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    define buffer buf_schedule-attr for ub.schedule-attr.

    run schedule-attr-name in this-procedure (
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
    if p-code begins ({&attr-schd-free-id} + {&delim-par})
    and entry(2, p-code, {&delim-par}) = '':U then do:
      find first buf_schedule-attr no-lock     /* Ищем атрибут */
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  begins p-code
      no-error .
    end.
    else do:
      find first buf_schedule-attr no-lock     /* Ищем атрибут */
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  = p-code
      no-error .
    end.
    if available buf_schedule-attr
    then do:
        assign
            p-value = buf_schedule-attr.attr-value
        .
    end.
    else do:
      if p-code begins ({&attr-schd-free-id} + {&delim-par} ) then do:
         run schedule-attr-get-free-props in this-procedure (input entry(2, p-code, {&delim-par}), output p-value).
      end.
      else do:
        assign
            p-value = if p-type = {&type-log} then "no":U else ""
        .
      end.
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
procedure schedule-attr-write :
do
on error undo, return error
:
define input parameter p-cre-db-num  as integer   no-undo.      /* PI строки расписания */
define input parameter p-task-type   as character no-undo.
define input parameter p-task-num    as integer   no-undo.
define input parameter p-code        as character no-undo.      /* код атрибута */
define input parameter p-value       as character no-undo.      /* значение атрибута */

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    define buffer buf_schedule-attr for ub.schedule-attr .

    run schedule-attr-name in this-procedure (
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
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        create buf_schedule-attr.
        assign
          buf_schedule-attr.cre-db-num = p-cre-db-num
          buf_schedule-attr.task-type  = p-task-type
          buf_schedule-attr.task-num   = p-task-num
          buf_schedule-attr.attr-code  = p-code
          buf_schedule-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_schedule-attr.attr-value = p-value
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
procedure schedule-attr-delete :
do
on error undo, return error
:
define input  parameter p-cre-db-num  as integer   no-undo.      /* PI строки расписания */
define input  parameter p-task-type   as character no-undo.
define input  parameter p-task-num    as integer   no-undo.
define input  parameter p-code        as character no-undo.      /* код атрибута */
define output parameter p-deleted     as logical   no-undo.

    define buffer buf_schedule-attr for ub.schedule-attr .

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    run schedule-attr-name in this-procedure (
          input p-code            /* p-code           */
        , output v-type           /* p-type           */
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
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
        delete buf_schedule-attr.
        assign
            p-deleted = yes
        .
    end.
end.
end procedure.

procedure schedule-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-code :
      &scop attr-code attr-schedule-param-list-h
      {&attr-news-code}
      &scop attr-code attr-schedule-obj-list-h
      {&attr-news-code}
      &scop attr-code attr-schedule-oss-list-h
      {&attr-news-code}
      &scop attr-code attr-schedule-gds-list-h
      {&attr-news-code}
      &scop attr-code attr-schedule-doc-type-list-h
      {&attr-news-code}
      &scop attr-code attr-schedule-date-list-h
      {&attr-news-code}
      &scop attr-code attr-schedule-filter-h
      {&attr-news-code}
      &scop attr-code attr-schedule-filter-2-h
      {&attr-news-code}
      &scop attr-code attr-schd-free-id
      {&attr-news-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
end.
end procedure.

/*==========================================================================*/
procedure schedule-attr-extract-logical :
do
on error undo, return error
:
define input  parameter p-parameter-number   as integer      no-undo.
define input  parameter p-parameter-list     as character    no-undo.
define output parameter p-parameter-value   as logical      no-undo.

    if num-entries( p-parameter-list ) > p-parameter-number - 1
    then do:
        assign
            p-parameter-value   = ( entry( p-parameter-number, p-parameter-list ) = "yes" )
        .
    end.
    else do:
        assign
            p-parameter-value   = no
        .
    end.
end.
end procedure. /* extract-parameter */

/*получение идентификатора произвольного задания*/
procedure schedule-attr-get-free-id :
do
on error undo, return error return-value
:
  define input  parameter p-cre-db-num  as integer   no-undo.      /* PI строки расписания */
  define input  parameter p-task-type   as character no-undo.
  define input  parameter p-task-num    as integer   no-undo.
  define output parameter p-free-id     as character no-undo.      /* идентификатор произв задания */

  define buffer buf_schedule-attr for ub.schedule-attr.
  find first buf_schedule-attr no-lock     /* Ищем атрибут */
      where buf_schedule-attr.cre-db-num = p-cre-db-num
        and buf_schedule-attr.task-type  = p-task-type
        and buf_schedule-attr.task-num   = p-task-num
        and buf_schedule-attr.attr-code  begins  ({&attr-schd-free-id} + {&delim-par})
  no-error .
  if available buf_schedule-attr then
  assign
  p-free-id = entry(2, buf_schedule-attr.attr-code, {&delim-par})
  no-error
  .
end.
end procedure. /* schedule-attr-get-free-id  */

/*получение значения атрибута {&attr-schd-free-id} из временной таблицы temp-schedule-free созданной на основе файла shd-free.d */

procedure schedule-attr-get-free-props :
  define input parameter p-free-id as character no-undo .
  define output parameter p-value as character no-undo .
  define buffer buf_temp-schedule-free for temp-schedule-free.

  do
  on error undo, return error return-value
  :

    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free then do:
      assign
      p-value = buf_temp-schedule-free.free-task-name       + {&delim-par} +
                buf_temp-schedule-free.proc-run-name        + {&delim-par} +
                buf_temp-schedule-free.proc-param-edit-name + {&delim-par} +
                buf_temp-schedule-free.conf-param           + {&delim-par} +
                string(buf_temp-schedule-free.is-gbd)       + {&delim-par} +
                string(buf_temp-schedule-free.is-ubd)       + {&delim-par} +
                string(buf_temp-schedule-free.enable-concurrent-0) + {&delim-par} +
                string(buf_temp-schedule-free.enable-concurrent-db) + {&delim-par} +
                buf_temp-schedule-free.other-info
      .
    end.
    else do:
     if p-free-id <> '':U then return error substitute("&1 &2 &3&4Неопределены процедуры для работы с произвольной задачей по расписанию&4" +
                           "id произвольной задачи - &5"
                           ,vss-workfile
                           ,vss-revision
                           ,vss-description
                           ,{&new-line}
                           ,p-free-id).
    end.
  end.

end procedure. /* schedule-attr-get-free-props */

procedure schedule-attr-is-rum-free-id :
define input parameter p-free-id as character no-undo .
define output parameter p-is-rum as logical no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
do
on error undo, return error
:
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free
    and buf_temp-schedule-free.is-rum
    then do:
      p-is-rum = yes.
    end.
end.
end procedure. /* schedule-attr-is-rum-free-id */

procedure schedule-attr-fill-free-props :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
define variable v-answer as logical no-undo .

  do
  on error undo, return error substitute("&1 &2 &3&4&5&4"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        ,error-status:get-message(1) )
  :
    run gbl/filename.p (
                    input 'cmp/shd-free.d'
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) .
    input from value(v-full-path).
    repeat :
      create buf_temp-schedule-free.
      import buf_temp-schedule-free.
    END.
    input close.
    _ff:
    for each buf_temp-schedule-free :
      if buf_temp-schedule-free.free-id = '':U then do:
         delete buf_temp-schedule-free.
         next _ff.
       end.
       run schedule-attr-check-enc in this-procedure (
                                                    input  buf_temp-schedule-free.free-id
                                                   ,input  (buf_temp-schedule-free.proc-run-name +
                                                            buf_temp-schedule-free.proc-param-edit-name +
                                                            buf_temp-schedule-free.conf-param +
                                                            string(buf_temp-schedule-free.is-gbd) +
                                                            string(buf_temp-schedule-free.is-ubd) +
                                                            string(buf_temp-schedule-free.enable-concurrent-0) +
                                                            string(buf_temp-schedule-free.enable-concurrent-db) +
                                                            string(buf_temp-schedule-free.other-info)
                                                            )
                                                    ,input  buf_temp-schedule-free.enc-key
                                                    ,output v-answer    ) no-error .
       if error-status:error
       or not v-answer then delete buf_temp-schedule-free.
     end.
  end.
end procedure. /* schedule-attr-fill-free-props */

/* функция реверсии последовательности символов в строке */
Function schedule-attr-reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .

   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.


procedure schedule-attr-check-enc.

  define input  parameter p-free-id   as character no-undo .  /* метка free-id */
  define input  parameter p-value     as character no-undo .  /* значение полей строки расписания */
  define input  parameter p-enc-value as character no-undo .  /* кодированное значение */
  define output parameter p-answer    as logical   no-undo .  /* yes - если значение закодировано правильно */

  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .


  assign
  tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value)) .
  .


  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .

  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.

  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.

end.             /* check-enc */

procedure schedule-attr-conf-enc.
  define input  parameter p-free-id   as character no-undo .  /* free-id*/
  define input  parameter p-value     as character no-undo .  /* значение параметра */
  define output parameter p-enc-value as character no-undo .  /* кодированное значение */

  define variable tmp         as character no-undo .
  assign
    tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value))
  .

  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output p-enc-value
    ) no-error .

  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.             /* conf-enc */

{ adm/pswd-enc.i
  &proc-name=schedule-attr-pswd-enc
}

/* $Workfile$ e n d */