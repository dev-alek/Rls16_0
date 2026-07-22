/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с параметрами конфигурации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

нельзя использовать Like для возможности компиляции Stand-alone!!!!

*/

/* Таблица для загрузки состояния конфигурации */
&glob config-field    ~
    field param-code    as character   format "x(8)"        column-label "Код"                           ~
    field param-type    as character                        column-label "Тип"                           ~
    field param-value   as character   format "x(250)"      column-label "Значение"                      ~
    field param-encoded as character                        column-label "Кодированное значение"         ~
    field host-code     as integer                          column-label "Фирма"                         ~
    field obj-type      as character                        column-label "Тип объекта"                   ~
    field obj-code      as integer     format ">>>>>>"      column-label "Код объекта"                   ~
    field conf-type     as character                        column-label "Кодировка"                     ~
    field beg-date      as date                             column-label "Начало действия параметра"     ~
    field end-date      as date                             column-label "Окончание действия параметра"  ~
    field db-num        as integer     format ">>>>>"       column-label "БД"                            ~
    field stts          as integer                          column-label "Статус"


define {&new} shared temp-table cnf no-undo
    {&config-field}
    field db-key        as character   format "x(12)"       column-label "Ключ БД"
    field param-PS      as character   format "x(40)"       column-label "PS"
    field param-name    as character   format "x(30)"       column-label "Название"
    field is-changed    as logical initial false            column-label "Изменен"
    field NotUsed       as logical initial False            column-label "Выключен"
    field ErrorExist    as integer initial 0  format ">>"   column-label "Уровень ошибки" /* 1 - не критичные, 2 - критичные ошибки */
    index pi
      is unique
      param-code
      host-code
      obj-type
      obj-code
      beg-date
      end-date
      db-num
    index db-num
      db-num
    index db-key
      db-key
    index par-name
      is word-index
      param-name
    index par-value
      is word-index
      param-value
 .


&glob except-list stts         ~
                  param-PS     ~
                  param-name   ~
                  is-changed   ~
                  NotUsed      ~
                  ErrorExist

 /* Tаблица, содержащая протокол работы если протокол ведется не в файл. */

def {&new} shared temp-table log-table no-undo
    field stroka       as character format "x(256)".

def {&new} shared variable err-level as integer no-undo.  /* уровень серьезности обнаруженной ошибки */

&glob delimiter       "`"

/* имена файлов по умолчанию   */
&glob cnf-file        "config.cfg"


&glob fields  ~{&buf1}param-code ~{&buf2}param-code ~{&link-word}    ~
              ~{&buf1}host-code  ~{&buf2}host-code  ~{&link-word}    ~
              ~{&buf1}obj-type   ~{&buf2}obj-type   ~{&link-word}    ~
              ~{&buf1}obj-code   ~{&buf2}obj-code   ~{&link-word}    ~
              ~{&buf1}beg-date   ~{&buf2}beg-date   ~{&link-word}    ~
              ~{&buf1}end-date   ~{&buf2}end-date   ~{&link-word}    ~
              ~{&buf1}db-num     ~{&buf2}db-num


&glob log-err                                                        ~
        if error-status:error then do:                               ~
           run log-sys-error in str-hdl ("Системная ошибка").        ~
           undo, return "2" .                                              ~
        end.