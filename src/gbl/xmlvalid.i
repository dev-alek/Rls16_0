/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор строки XML с проверкой тэгов

Автор: Хныкин Павел Андреевич
Дата создания: 10/25/05
Author: Pavel Khnykin
Creation date: 10/25/05

Required:
    { gbl/xmlparse.i }

Вызов:
  run xmlvalid in this-procedure
    ( input p-handle
    , input p-buffer-string
    , input p-xmlvalid-error-mode
    ) .

Параметры:
    p-handle               - handle вызывающей процедуры
    p-buffer-string        - строка из XML-файла
    v-xmlvalid-error-mode  - поведение при ошибке:
        'fatal' - завершить проверку и return error.
        'skip'  - если пытаемся закрыть тэг, который выше по уровню, чем
                  текущий, то закрываем его и весь считанный текст считаем
                  его значением. Открытые тэги более высокого уровн
                  удаляются из стека.
                  если пытаемся закрыть несуществующий тэг - операци
                  закрытия тэга игнорируется.

В вызывающей программе могут быть определены функции:
    cb-xmlvalid-procedure-not-found ( input char, input char, input char )   -
        вызывается в случае, если не определена
        процедура cb-xmlparse-*-tag-* для соответствующего тэга.
        первый параметр - тип события, может принимать значения :
          'tag-start', 'tag-end', 'text'
        второй параметр - значение
        третий - при 'tag-start', строка параметров

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scop xmlvalid-vartype "character,integer,decimal,date,logical"

define variable v-xmlvalid-error-mode       as character    no-undo.
define variable v-xmlvalid-tag-value        as character    no-undo.
define variable v-xmlvalid-current-level    as integer      no-undo.
define variable v-xmlvalid-in-tag           as logical      no-undo.
define variable v-xmlvalid-read-vartype     as logical      no-undo.

define temp-table temp_xmlvalid-taglist no-undo
    field level-num as integer
    field tag-name  as character
    index lv  is primary unique level-num
.
define temp-table temp_xmlvalid-field-types no-undo
    field field-name as character
    field field-type as character
    index fn is primary unique field-name
.

/*==========================================================================*/
procedure xmlvalid :
  do
  on error undo, return error
  :
    def input parameter p-handle                as handle   no-undo.
    def input parameter p-buffer-string         as char     no-undo.
    def input parameter p-xmlvalid-error-mode   as char     no-undo.

    assign
        v-xmlvalid-error-mode   = p-xmlvalid-error-mode
    .
    run xmlparse in this-procedure (
              input p-handle
            , input p-buffer-string
            , input {&xmlparse-call-all}
    ).
  end.
end procedure. /* xmlvalid */


/*==========================================================================*/
procedure cb-xmlparse-tag-start-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = yes
    .
    run cb-xmlparse-procedure-not-found in this-procedure (
          input "tag-start":U
        , input "varType":U
        , input p-param
    ).
end.
end procedure. /* cb-xmlparse-vartype */

/*==========================================================================*/
procedure cb-xmlparse-tag-end-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = no
    .
    define variable v-vartype-list     as character         no-undo.
    for each temp_xmlvalid-field-types
    :
        /*---START--------- Проверка соответствия считанных типов данных стандартным ---------------------*/
        if index( {&xmlvalid-vartype}, temp_xmlvalid-field-types.field-type ) = 0
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен неверно. "
                                                    + "Тэг " + temp_xmlvalid-field-types.field-name
                                                    + " не будет проверен на соответствие типу данных"
                                        ).
            delete temp_xmlvalid-field-types.
        end.
        else do:
                                        assign
                                            v-vartype-list = v-vartype-list + temp_xmlvalid-field-types.field-name
                                            + temp_xmlvalid-field-types.field-type + {&new-line}
                                        .
        end.
        /*---END----------- Проверка соответствия считанных типов данных стандартным ---------------------*/
    end.
    run cb-xmlparse-procedure-not-found in this-procedure (
                                        input "tag-end":U
                                        , input "varType":U
                                        , input p-param
                                                        ).
end.
end procedure. /* cb-xmlparse-vartype */

/*==========================================================================*/
procedure cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
def input parameter p-tag-type      as char no-undo.
def input parameter p-tag-value     as char no-undo.
def input parameter p-param-value   as char no-undo.

def buffer buf_temp_xmlvalid-taglist for temp_xmlvalid-taglist.

def var v-found    as logical  no-undo.

if p-tag-type = "tag-start"
then do:
    assign
        v-xmlvalid-current-level = v-xmlvalid-current-level + 1
        v-xmlvalid-in-tag        = yes
    .
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
    no-error.
    if not available temp_xmlvalid-taglist
    then do:
        create temp_xmlvalid-taglist.
        assign
            temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
        .
    end.
    assign
        temp_xmlvalid-taglist.tag-name = p-tag-value
        v-xmlvalid-tag-value = ""
    .
    if v-xmlvalid-read-vartype = yes and p-tag-value <> "varType":U
    then do:
    /*---START--------- Идем внутри тэга varType. Работаем с определением типов тэгов ---------------------*/
        find first temp_xmlvalid-field-types
             where temp_xmlvalid-field-types.field-name = p-tag-value
        no-error.
        if available temp_xmlvalid-field-types
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен повторно"
                                        ).
        end.
        else do:
            create temp_xmlvalid-field-types.
            assign
                temp_xmlvalid-field-types.field-name = p-tag-value
            .
        end.
    /*---END----------- Идем внутри тэга varType. Работаем с определением типов тэгов ---------------------*/
    end.
end.        /* if p-tag-type = "tag-start" */
if p-tag-type = "tag-end"
then do:
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
           and temp_xmlvalid-taglist.tag-name  = p-tag-value
    no-error.
    if available temp_xmlvalid-taglist
    then do:
        assign
            v-xmlvalid-current-level = v-xmlvalid-current-level - 1
            v-xmlvalid-in-tag        = no
        .
    end.        /* if temp_xmlvalid-taglist.tag-name = p-tag-value */
    else do:
        if v-xmlvalid-error-mode = 'fatal'
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Ошибка: Попытка закрыть не открытый тэг"
                                        ).
        end.        /* if v-xmlvalid-error-mode = 'fatal' */
        else do:
            find first temp_xmlvalid-taglist
                 where temp_xmlvalid-taglist.tag-name = p-tag-value
            no-error.
            if not available temp_xmlvalid-taglist
            then do:
                assign
                    v-xmlvalid-tag-value = v-xmlvalid-tag-value + "</" + p-tag-value + ">" + {&new-line}
                .
            end.        /* if not available temp_xmlvalid-taglist  */
            else do:
                for each buf_temp_xmlvalid-taglist
                   where buf_temp_xmlvalid-taglist.level-num > temp_xmlvalid-taglist.level-num
                :
                    assign
                        v-xmlvalid-tag-value = "<" + buf_temp_xmlvalid-taglist.tag-name + ">" + {&new-line} + v-xmlvalid-tag-value
                        v-xmlvalid-current-level = temp_xmlvalid-taglist.level-num - 1
                    .
                end.
            end.        /* Нашли подходящий тэг, закрыли его, удалили из стека все открытые после него тэги
                           и поместили их названия в строку-значение тэга */
        end.        /* if v-xmlvalid-error-mode <> 'fatal' */
    end.        /* if temp_xmlvalid-taglist.tag-name <> p-tag-value */
end.        /* if p-tag-type = "tag-end" */

if p-tag-type = "text"
then do:
    if v-xmlvalid-read-vartype = yes
    then do:
        /*---START--------- Идем внутри тэга varType. Работаем с определением типов тэгов ---------------------*/
        if available temp_xmlvalid-field-types
        then do:
            assign
                temp_xmlvalid-field-types.field-type = v-xmlvalid-tag-value
            .
        end.
        /*---END----------- Идем внутри тэга varType. Работаем с определением типов тэгов ---------------------*/
    end.        /* if v-xmlvalid-read-vartype = yes  */
    else do:
        find first temp_xmlvalid-field-types
            where temp_xmlvalid-field-types.field-name = temp_xmlvalid-taglist.tag-name
        no-error.
        if available temp_xmlvalid-field-types
        then do:
            /*---START--------- Проверка типа значения тэга ---------------------*/
            /*---END----------- Проверка типа значения тэга ---------------------*/
        end.
        else do:
            /*---START--------- Если тип тэга не задан, то проверка не производится ---------------------*/
            /*---END----------- Если тип тэга не задан, то проверка не производится ---------------------*/
        end.
    end.        /* if v-xmlvalid-read-vartype = no  */
    assign
        v-xmlvalid-tag-value = v-xmlvalid-tag-value + p-tag-value
    .
end.        /* if p-tag-type = "text" */
run run-cb-xmlvalid-procedure-not-found in this-procedure
                                        (     input this-procedure :handle
                                            , input p-tag-type
                                            , input p-tag-value
                                            , input p-param-value
                                        ).
end.
end procedure. /* cb-xmlparse-tag-start-<имя_тэга>  */







/*==========================================================================*/
procedure run-cb-xmlvalid-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle   no-undo.
    def input parameter p-data-type         as char     no-undo.
    def input parameter p-data-value        as char     no-undo.
    def input parameter p-param-value       as char     no-undo.

    if lookup("cb-xmlvalid-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-procedure-not-found in p-handle (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlvalid-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlvalid-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlvalid-procedure-not-found"
                                ).
    end.

end.
end procedure. /* cb-xmlvalid-procedure-not-found */


/*==========================================================================*/
procedure run-cb-xmlvalid-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.

    if lookup("cb-xmlvalid-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-error in p-handle  (input p-error-message).
    end.
end.
end procedure. /* run-cb-xmlvalid-error */





/*==========================================================================*/
procedure run-cb-xmlvalid-procedure :
do
on error undo, return error
:
def input parameter p-handle            as handle no-undo.
def input parameter p-procedure-name    as char no-undo.

def var v-data-type     as char no-undo.
def var v-data-value    as char no-undo.
def var v-param-value   as char no-undo.

    if lookup( p-procedure-name, p-handle :internal-entries) > 0
    then do:
        run value(p-procedure-name) in p-handle no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы " + p-procedure-name
                                    ).
        end.
    end.
    else do:
        if substring(p-procedure-name, 1, 20) = "cb-xmlvalid-tag-end-"
        then do:
            assign
                v-data-type     = "tag-end"
                v-data-value    = substring(p-procedure-name, 21)
            .
        end.
        else do:
            if substring(p-procedure-name, 1, 22) = "cb-xmlvalid-tag-start-"
            then do:
                assign
                    v-data-type     = "tag-start"
                    v-data-value    = substring(p-procedure-name, 23)
                .
            end.
            else do:
                assign
                    v-data-type     = "text"
                    v-data-value    = p-procedure-name
                .
            end.
        end.
        run run-cb-xmlvalid-procedure-not-found in this-procedure
                                               (   input p-handle
                                                  , input v-data-type
                                                  , input v-data-value
                                                  , input v-param-value
                                                ).
    end.
end.
end procedure. /* run-callback-procedure */

/* $Workfile$ e n d */