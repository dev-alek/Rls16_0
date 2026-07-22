/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись в лог

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

    Вывод в LOG

    {1} - def
        {2} - имя файла, куда выводить. Если вторым параметром передано "''", вывод вестись не будет.
        {3} - можно указать 'no-create', тогда вывод будет идти только в случае, если log-файл уже существует
    {1} - write :
        {2} - отступ (в единицах log-tab-spaces);  0 - не выводить дату (1 - начальный отступ)
        {3} - что выводить;                       "&Line"  - Вывести разделительную линию из символов "-"
                                                  "&DLine" - Вывести разделительную линию из символов "="

        можно использовать процедуру writelog вместо вызова out-log.i с параметром write,
        это может быть удобно, если {3} на одной строке не помещается. Для имени файла можно передавать
        переменную log-file-name
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

    def var log-file-name as char no-undo.

&if "{3}" = "no-create" &then
    if search({2}) = ?
    then do:
        assign
            log-file-name = ""
        .
    end.
    else do:
        assign
            log-file-name = {2}
        .
    end.
&else
    assign
        log-file-name = {2}
    .
    if log-file-name <> "":U
    then do:
        if search( {2} ) = ?
        then do:
            output to value( {2} ).
            output close.
        end.
    end.
&endIF
&endif

&if "{1}" = "def" or "{1}" = "def-proc" &then
    &scop log-tab-spaces 2
    &scop log-line-size 80

    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    /*
    Процедура делает запись в файле, определенном параметром p-file-name.
    Если p-file-name = "", то лог не ведется.
    Запись выглядит следующим образом:
        <Пробелы, определяемые параметром p-log-level><Текущая дата><p-log-string>
    Специальные значения для p-log-level:
        0 - не выводить дату (1 - без отступа)
    Специальные значения для p-log-string:
        "&Line"  - Вывести разделительную линию из символов "-"
        "&DLine" - Вывести разделительную линию из символов "="
        Длина разделительных линий задается в log-line-size.
    */

    if p-file-name <> ""
    then do:



    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED {&new-line}.
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", {&log-line-size})
                ELSE IF p-log-string = "&DLine" THEN FILL("=", {&log-line-size})
                ELSE fill(" ", p-log-level * {&log-tab-spaces}) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.

&endif
&if  "{1}" = "def-proc-extended" &then
    &scop log-tab-spaces 2
    &scop log-line-size 80

    DEF STREAM stm-log.
    PROCEDURE writelog-extended:
    DEFine INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEFine INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    define input parameter p-userid    as character no-undo .
    DEFine INPUT PARAMETER p-log-string AS CHARACTER  NO-UNDO.
    define input parameter p-time-to-wait-seconds as integer no-undo .

    define variable v-log-string as character no-undo .
    /*
    Процедура делает запись в файле, определенном параметром p-file-name.
    Если p-file-name = "", то лог не ведется.
    Запись выглядит следующим образом:
        <Пробелы, определяемые параметром p-log-level><Текущая дата><p-log-string>
    Специальные значения для p-log-level:
        0 - не выводить дату (1 - без отступа)
    Специальные значения для p-log-string:
        "&Line"  - Вывести разделительную линию из символов "-"
        "&DLine" - Вывести разделительную линию из символов "="
        Длина разделительных линий задается в log-line-size.
    */

    if p-file-name <> ""
    then do:



    /*обработаем строку как в простом writelog*/
    assign
    v-log-string = ({&carriage-return} + {&new-line}) +
                   (IF (p-log-level = 0
                        OR p-log-string = "&DLine"
                        OR p-log-string = "&Line")
                    then '':U
                    else (p-userid + {&space-char} + cur-time-string-sec() + {&space-char})).
    CASE v-log-string:
      when "&Line" THEN do:
        v-log-string = v-log-string + FILL("-", {&log-line-size}).
      end.
      when "&DLine" THEN do:
        v-log-string = v-log-string + FILL("=", {&log-line-size}).
      end.
      otherwise do:
        v-log-string = v-log-string +  fill({&space-char}, p-log-level * {&log-tab-spaces}) +
                       replace(p-log-string, {&new-line}, ({&carriage-return} + {&new-line})).
      end.
    END CASE.
    run gbl/fileapnd.p (
                     input p-file-name
                    ,input v-log-string
                    ,input p-time-to-wait-seconds) no-error .
    if error-status:error then return error return-value .
    end.
    END PROCEDURE.
&endif
&if "{1}" = "write" &then
    run writelog in this-procedure (log-file-name, {2}, {3}) .
&endif

/* $Workfile$ e n d */