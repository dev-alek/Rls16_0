/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

OpenXML. Процедуры для работы с форматом XML и выводом в LOG и EDItor

Автор: Белоусов Илья Александрович
Дата создания: 04/21/06
Author: Ilia Belousov
Creation date: 04/21/06

Required:

{ gbl/cur-time.i }
{ gbl/xmlchar.i  }

Пример разбора XML-файла (уникальные тэги):

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Записать информацию в файл в режиме добавления. Версия с позиционированием на конец файла".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/xmlchar.i  }
{ str/xmllib.i   }

&scoped-define xml-file d:\paramkas.xml
&scoped-define out-file d:\paramkas.out

    define variable v-full-filename as character  no-undo.

    define buffer buf_rec-fld      for temp_xmllib_rec-fld.
    define buffer buf_rec          for temp_xmllib_rec.
do
for buf_rec-fld
  , buf_rec
on error undo, return error
:
    assign
        v-full-filename   = search( "{&xml-file}" )
    .
    if v-full-filename <> ?
    then do:
        run xmllib-clear-parse-data in this-procedure.
        run xmllib-add-rec-fld in this-procedure ( input "GroupSpec":U, input "GroupSpecCode":U     ).
        run xmllib-add-rec-fld in this-procedure ( input "GroupSpec":U, input "GroupSpecFullName":U ).
        run xmllib-add-rec-fld in this-procedure ( input "GroupSpec":U, input "GroupSpecStatus":U   ).

        run xmllib-add-rec-fld in this-procedure ( input "Parameter":U      , input "ParameterName":U   ).
        run xmllib-add-rec-fld in this-procedure ( input "Parameter":U  , input "ParameterValue":U   ).

        run xmllib-parse-file in this-procedure (
            input v-full-filename
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip substitute( "Ошибка разбора файла &1", v-full-filename )
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        output to {&out-file}.
        for each buf_rec
        on error undo, return error
        :
            put unformatted
                substitute( "&1&2&1&3&1", {&NEW-LINE}, fill( "=", 80 ), buf_rec.recName )
            .
            for each buf_rec-fld
               where buf_rec-fld.rec-key = buf_rec.rec-key
            on error undo, return error
            :
                put unformatted
                    substitute( "&1&2 = &3", {&NEW-LINE}, buf_rec-fld.fldName, buf_rec-fld.fldValue )
                .
            end.
        end.
        output close.
    end.
end.

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i           }

&scoped-define Tabspaces 4
&scoped-define LogLineSize 80

&global-define xmllib-minimum-free-mbytes 200       /* Минимальное свободное место на диске */
&global-define xmllib-check-freespace-size 1048576  /* Для частоты проверки на свободное место, в байтах */
&global-define xmllib-maximum-file-size 100         /* Размер файла выгрузки, по достижению которого выгружается текущая операция и открывается новый файл. */
&global-define xmllib-temp-extension "tmp"          /* Расширение временного файла */

define stream stmXMLOut.
define stream stmXMLLog.
define stream strXMLIn.


define temp-table temp_xmllib_rec-list no-undo
    field recName       as character
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field closed        as logical

    index pi is primary unique
        recName
        recLevel
    index cl
        closed
.
define temp-table temp_xmllib_rec-fld-list no-undo
    field recName       as character
    field recLevel      as integer
    field fldName       as character
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field closed        as logical

    index pi is primary unique
        recName
        recLevel
        fldName

    index fn
        fldName
    index cl
        closed
.
define temp-table temp_xmllib_rec no-undo
    field rec-key       as integer
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field recName       as character
    field closed        as logical

    index pi is primary unique
        rec-key
    index nm
        recName
        closed
        rec-key
    index cl
        closed
    index rlv
        recName
        recLevel
        closed
        rec-key
.
define temp-table temp_xmllib_rec-fld no-undo
    field fld-key       as integer
    field rec-key       as integer
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field fldName       as character
    field fldValue      as character
    field closed        as logical

    index pi is primary unique
        fld-key
    index nm
        rec-key
        fldName
        closed
        fld-key
    index cl
        closed
.

define variable v-xmllib-rec-key            as integer      no-undo .
define variable v-xmllib-rec-fld-key        as integer      no-undo .
define variable v-xmllib-dirname            as character    no-undo .
define variable v-xmllib-filename           as character    no-undo .
define variable v-xmllib-log-filename       as character    no-undo .
define variable v-xmllib-log-handle         as handle       no-undo .
define variable v-xmllib-log-proc-name      as character    no-undo .
define variable v-xmllib-error-status       as logical      no-undo .
define variable v-xmllib-sax-reader-handle  as handle       no-undo .
define variable v-xmllib-prg-bar-handle     as handle       no-undo .
define variable v-xmllib-codepage-convert   as logical      no-undo .
define variable v-xmllib-codepage-source    as character    no-undo .
define variable v-xmllib-codepage-target    as character    no-undo .

/*==========================================================================*/
procedure xmllib-clear-parse-data :

do
on error undo, return error
:
    empty temp-table temp_xmllib_rec-list.
    empty temp-table temp_xmllib_rec-fld-list.
    empty temp-table temp_xmllib_rec.
    empty temp-table temp_xmllib_rec-fld.
end.
end procedure. /* xmllib-clear-parse-data */

procedure xmllib-add-rec-fld :
define input parameter p-rec-name       as character        no-undo.
define input parameter p-rec-fld-name   as character        no-undo.

    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find first buf_rec-list
         where buf_rec-list.recName = p-rec-name
    no-error.
    if not available buf_rec-list
    then do:
        create buf_rec-list.
        assign
            buf_rec-list.recName        = p-rec-name
            buf_rec-list.recOpenLine    = 0
            buf_rec-list.recCloseLine   = 0
            buf_rec-list.closed         = yes
        .
    end.
    find first buf_rec-fld-list
         where buf_rec-fld-list.recName = p-rec-name
           and buf_rec-fld-list.fldName = p-rec-fld-name
    no-error.
    if not available buf_rec-fld-list
    then do:
        create buf_rec-fld-list.
        assign
            buf_rec-fld-list.recName        = p-rec-name
            buf_rec-fld-list.fldName        = p-rec-fld-name
            buf_rec-fld-list.fldOpenLine    = 0
            buf_rec-fld-list.fldCloseLine   = 0
            buf_rec-fld-list.closed         = yes
        .
    end.
end.
end procedure. /* xmllib-add-rec-fld */
/*========================================================================*/
/*
    Процедура открывает тэг
    input:
        v-tag-level         - условный уровень тэга ( количество пробелов от начала файла * {&Tabspaces} )
        v-tag-name          - имя тэга
        v-tag-value         - значение тэга,
                              можно передавать и значения типа 'Адрес="ул. Салтыкова"'
*/
procedure xmllib-tag-open:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.

do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2<&3&4&5>"
            , {&new-line}
            , fill(" ", {&Tabspaces} * v-tag-level)
            , v-tag-name
            , ( if v-tag-value = "":U or v-tag-value = ? then "":U else " ":U )
            , v-tag-value
        )
    .
end.
end procedure.


/*========================================================================*/
/*
    Процедура создает закрытый тэг, заполняя его значением из v-tag-attributes
        v-tag-level         - условный уровень тэга (количество пробелов от начала файла * {&Tabspaces})
        v-tag-name          - имя тэга
        v-tag-value         - текст, который нужно вписать между тэгами последнего уровня.
                                Можно передавать и значения типа 'Адрес="ул. Салтыкова"'
        v-empty-mode        - что делать, если v-tag-attributes=? или v-tag-attributes="":U
            0  или любое из не перечисленных - не выводить ничего
            1 - выводить начало и конец тэга
            2 - то же, что и 0, но ничего не выводит и в случае v-tag-attributes = "0"
            3 - то же, что и 0, но ничего не выводит и в случае v-tag-attributes = "yes"
*/
procedure xmllib-tag-put:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.

do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "":U and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "":U and v-tag-value <> ? and v-tag-value <> "0":U))
    or (v-empty-mode = 3 and (v-tag-value <> "":U and v-tag-value <> ? and caps(v-tag-value) <> "no":U))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            substitute( "&1&2<&3>&4</&3>"
                , {&new-line}
                , fill(" ":U, {&Tabspaces} * v-tag-level)
                , v-tag-name
                , v-tag-value
            )
        .
    end.
end.
end procedure.

/*==========================================================================*/
procedure xmllib-tag-put-null :
define input parameter p-tag-level  as integer      no-undo.
define input parameter p-tag-name   as character    no-undo.

do
on error undo, return error
:
    assign
        p-tag-name = trim( p-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( '&1&2<&3 nil="true" /&3>'
            , {&new-line}
            , fill(" ":U, {&Tabspaces} * p-tag-level)
            , p-tag-name
        )
    .
end.
end procedure. /* xmllib-tag-put-null */

/*========================================================================*/
/*  Процедура закрывает тэг

    input:
        v-tag-level - условный уровень тэга (количество пробелов от начала файла * {&Tabspaces})
        v-tag-name  - имя тэга
*/
procedure xmllib-tag-close:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.

do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2</&3>"
            , {&new-line}
            , fill( " ":U, {&Tabspaces} * v-tag-level)
            , v-tag-name
        )
    .
end.
end procedure.

/*========================================================================*/
/*
  Процедура делает запись в файле, определенном параметром v-filename.
  Запись выглядит следующим образом:
     <Текущая дата><Пробелы, определяемые параметром v-log-level><v-out-string>
  Специальные значения для v-log-level:
       0 - не выводить дату (1 - без отступа)
  Специальные значения для v-out-string:
      "&Line"  - Вывести разделительную линию из символов "-"
      "&DLine" - Вывести разделительную линию из символов "="
    Длина разделительных линий задается в LogLineSize.
*/
procedure xmllib-write-log:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.

do
on error undo, return error
:
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        {&new-line}
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine":U
          or v-out-string = "&Line":U
          then "":U
          else cur-time-string-sec() + " ":U )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line":U
          then fill( "-":U, {&LogLineSize} )
          else if v-out-string = "&DLine":U
               then fill( "=":U, {&LogLineSize} )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.

/*========================================================================*/
/*
  Процедура выводит запись в editor, определенный параметром v-editor-handle.
  Запись выглядит следующим образом:
     <Текущая дата><Пробелы, определяемые параметром v-log-level><v-out-string>
  Специальные значения для v-log-level:
       0 - не выводить дату (1 - без отступа)
  Специальные значения для v-out-string:
      "&Line"  - Вывести разделительную линию из символов "-"
      "&DLine" - Вывести разделительную линию из символов "="
    Длина разделительных линий задается в LogLineSize.
*/
procedure xmllib-write-edt:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.

do
on error undo, return error
:
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine":U
                                          or v-out-string = "&Line":U
                                          then "":U
                                          else cur-time-string-sec() + " ":U
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line":U
                                          then fill( "-":U, {&LogLineSize} )
                                          else if v-out-string = "&DLine":U then fill("=":U, {&LogLineSize})
                                          else fill( " ":U, v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( {&new-line} ).
    end.
end.
end procedure.

/*========================================================================*/
/*
    Процедура делает видимым fill-in, определенный параметром v-fillin-handle.
*/
procedure xmllib-show-cnt:
define input parameter v-fillin-handle     as handle   no-undo.

do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.

/*========================================================================*/
/*
    Процедура скрывает fill-in, определенный параметром v-fillin-handle.
*/
procedure xmllib-hide-cnt:
define input parameter v-fillin-handle     as handle   no-undo.

do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.

/*========================================================================*/
/*
    Процедура выводит значение v-fillin-string в fill-in,
    определенный параметром v-fillin-handle.
*/
procedure xmllib-write-cnt:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.

do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.

/*========================================================================*/
procedure xmllib-write-header:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.

    define variable v-counter    as integer        no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + {&xmllib-temp-extension} ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run xmllib-tag-open( input 0, input "root"          , input "":U ).
    run xmllib-tag-open( input 0, input "THheader"        , input "":U ).
    run xmllib-tag-put( input 1 , input "THfileName"      , input p-xml-file-name + "xml":U  , input 0 ).
    run xmllib-tag-put( input 1 , input "THfileNumber"    , input string( p-file-number     ), input 0 ).
    run xmllib-tag-put( input 1 , input "THhavePrev"      , input string( p-have-prev       ), input 3 ).
    run xmllib-tag-put( input 1 , input "THprevFileName"  , input p-prev-filename            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run xmllib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run xmllib-tag-close( input 0, input "THheader" ).
    output stream stmXMLOut close.

    if p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + {&xmllib-temp-extension} ) convert target "1251" append.
        if p-first-file = yes
        then do:
            put stream stmXMLOut unformatted
                "<?xml version='1.0' encoding='windows-1251'?>"
            .
            run xmllib-tag-open( input 0, input "OpenXML", input "" ).
        end.
        run xmllib-tag-open( input 1, input "THfile", input "" ).
        run xmllib-tag-put( input 2, input "THfileName"       , input p-xml-file-name + "xml":U  , input 0 ).
        run xmllib-tag-put( input 2, input "THfileNumber"     , input string( p-file-number     ), input 0 ).
        run xmllib-tag-put( input 2, input "THhavePrev"       , input string( p-have-prev       ), input 3 ).
        run xmllib-tag-put( input 2, input "THprevFileName"   , input p-prev-filename            , input 0 ).
        do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
        :
            run xmllib-tag-put(
                input 2
                , input entry( 2 * v-counter, p-parameter-list )
                , input entry( 2 * v-counter + 1, p-parameter-list )
                , input 0
            ).
        end.
        run xmllib-tag-close( input 1, input "THfile" ).
        output stream stmXMLOut close.
    end.        /* p-list-file-name <> "":U */
end.
end procedure.

/*========================================================================*/
/*
    Процедура закрывает тэг root, переименовывает временный файл в .xml
*/
procedure xmllib-write-footer:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.

    define variable v-error-num     as integer           no-undo.

do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + {&xmllib-temp-extension} ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run xmllib-tag-open( input 0, input "footer", "" ).
        run xmllib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run xmllib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run xmllib-tag-close( input 0, input "footer" ).
    end.
    run xmllib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    /*- переименовать: .tmp -> .xml -*/
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + {&xmllib-temp-extension}
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    and p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + {&xmllib-temp-extension} ) convert target "1251" append.
            run xmllib-tag-close( input 0, input "OpenXML" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + {&xmllib-temp-extension}
            , input p-list-file-name + "xml":U
            , output v-error-num
        ).
    end.
end.
end procedure.

/*==========================================================================*/
/*
    Процедура вычисляет имя файлов для экспорта и лога экспорта в каталог,
    определённый параметром секции BGE, ключ outdir

    output:
        p-xml-file-name - имя файла для экспорта, без расширения, с точкой
        p-log-file-name - полное имя файла для лога
*/
procedure xmllib-filename :
define input parameter p-subdir             as character        no-undo.
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.

    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.

do
on error undo, return error
:
    get-key-value section "OXML" key "oxml-dir" value v-home-dir.
    if v-home-dir = ?
    then do:            /* нет ключа */
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip "Нет параметра oxml-dir в секции [OXML]."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if p-subdir <> "":U
    then do:
        assign
            v-home-dir = substitute( "&1/out/&2", v-home-dir, p-subdir )
        .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта в ini-файле."
          skip "Не удаётся создать каталог, указанный параметром"
          skip "oxml-dir в секции [OXML]."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input {&xmllib-temp-extension}
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + {&back-slash-char} + "actions.log"
        p-list-file-name    = v-home-dir + {&back-slash-char} + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure. /* xmllib-log-filename */

/*==========================================================================*/
procedure xmllib-check-file-size :
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.

    define variable v-current-position    as integer        no-undo.

do
on error undo, return error
:
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= {&xmllib-maximum-file-size}
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure. /* xmllib-check-space-and-file */


/*==========================================================================*/
procedure xmllib-parse-file :
define input parameter p-full-filename      as character        no-undo.

    define variable v-num-dirs              as integer      no-undo .
    define variable v-str                   as character    no-undo .
    define variable v-str-count             as int64        no-undo .
do
on error undo, return error
:
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      { gbl/working.i }
      input stream strXMLIn from value(p-full-filename) .
      repeat
      :
        import stream strXMLIn unformatted v-str no-error .
        assign
          v-str-count = v-str-count + 1
        .
      end.
      input stream strXMLIn close .
      { gbl/stopwork.i }

      run prg-bar_init-cb-handle in this-procedure ( input v-xmllib-prg-bar-handle ) .
      run prg-bar_new in this-procedure ( input 1 , input v-str-count) .
      run prg-bar_show in this-procedure .
    end.

    create sax-reader v-xmllib-sax-reader-handle.
    v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ).
    v-xmllib-sax-reader-handle :sax-parse( ) no-error.
    if error-status :error
    then do:
        run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                    ,vss-workfile
                                                                    ,vss-revision
                                                                    ,vss-description
                                                                    ,{&new-line}
                                                                    ,return-value
                                                                    ,trim(error-status :get-message(1))
                                                                    ,trim(error-status :get-message(2))
                                                                    ,trim(error-status :get-message(3)))
                                                  ).
        undo, return error .
    end.
    if v-xmllib-error-status <> no
    then do:
        run xmllib-parse-error in this-procedure (
            input "*** При обработке XML файла были ошибки."
        ).
        delete object v-xmllib-sax-reader-handle.
    end.
    delete object v-xmllib-sax-reader-handle.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_delete in this-procedure .
    end.
    /*
    v-xmllib-sax-reader-handle :sax-parse-first( ).
    do while
    v-xmllib-sax-reader-handle :parse-status <> SAX-COMPLETE
    :
        v-xmllib-sax-reader-handle :sax-parse-next( ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка разбора файла."
                skip "Строка:" v-xmllib-sax-reader-handle :locator-line-number
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
    */
end.
end procedure. /* xmllib-parse-file */

/*==========================================================================*/
procedure xmllib-parse-progressive :
define input parameter p-full-filename      as character no-undo .
define input parameter p-pack-data          as memptr no-undo .
define input parameter p-parse-first        as logical no-undo .
define input parameter p-first-err          as logical no-undo .
define output parameter p-parse-status as integer no-undo .

define variable v-num-dirs              as integer no-undo .
define variable glog                    as logical no-undo .
define variable v-pack-size             as int64 no-undo .  

do
on error undo, return error
:
  if p-parse-first then do:
    if valid-handle(v-xmllib-sax-reader-handle)
    then do:
    end.
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    create sax-reader v-xmllib-sax-reader-handle.
    
    /* 23/VIII-2018 - если файл уже загружен в mem-ptr - читаем из mem-ptr,
                      иначе читаем как раньше - из файла */
    v-pack-size = get-size (p-pack-data) .
    if v-pack-size > 0 then
      glog = v-xmllib-sax-reader-handle :set-input-source( "MEMPTR":U, p-pack-data ) no-error.
    else
      glog = v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ) no-error.
    if error-status :error
    or not glog
    then do:
      delete object v-xmllib-sax-reader-handle.
      run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                  ,vss-workfile
                                                                  ,vss-revision
                                                                  ,vss-description
                                                                  ,{&new-line}
                                                                  ,return-value
                                                                  ,trim(error-status :get-message(1))
                                                                  ,trim(error-status :get-message(2))
                                                                  ,trim(error-status :get-message(3)) )
                                                ).
      undo, return error .
    end.
    
    v-xmllib-sax-reader-handle :sax-parse-first( ) no-error.
  end. /*if p-parse-first then do:*/
  else do:
    v-xmllib-sax-reader-handle :sax-parse-next( ) no-error.
  end.
  if error-status :error
  then do:
    delete object v-xmllib-sax-reader-handle.
    run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                ,vss-workfile
                                                                ,vss-revision
                                                                ,vss-description
                                                                ,{&new-line}
                                                                ,return-value
                                                                ,trim(error-status :get-message(1))
                                                                ,trim(error-status :get-message(2))
                                                                ,trim(error-status :get-message(3)) )
                                              ).
    undo, return error .
  end.
  if v-xmllib-error-status <> no
  then do:
    run xmllib-parse-error in this-procedure (
        input "*** При обработке XML файла были ошибки."
    ).
    if p-first-err then do:
      delete object v-xmllib-sax-reader-handle.
    end.
    else do:
      v-xmllib-error-status = no.
    end.
  end. /*if v-xmllib-error-status <> no*/
  if v-xmllib-sax-reader-handle:parse-status = SAX-COMPLETE  then do:
    p-parse-status = SAX-COMPLETE.
    delete object v-xmllib-sax-reader-handle.
    return '':U.
  end.
  else do:
    p-parse-status = v-xmllib-sax-reader-handle:parse-status.
    return '':U.
  end.

end.
end procedure. /* xmllib-parse-file */


/*==========================================================================*/
procedure StartElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.
define input parameter p-attributes     as handle           no-undo.

    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_stepto in this-procedure ( input SELF:LOCATOR-LINE-NUMBER ) .
    end.

    find first buf_rec-list
         where buf_rec-list.recName = p-q-name
    no-error.
    if available buf_rec-list
    then do:        /* Имя тэга есть в списке записей */
        if buf_rec-list.closed = no
        then do:
            find first buf_rec-fld-list
                 where buf_rec-fld-list.recName = buf_rec-list.recName
                   and buf_rec-fld-list.fldName = p-q-name
            no-error.
            if available buf_rec-fld-list
            and buf_rec-list.recName = buf_rec-fld-list.recName
            then do:
                if buf_rec-fld-list.closed = no
                then do:        /* Есть незакрытое поле с этим именем. */
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка 1 открытия поля <&1> записи <&2>: Поле с этим именем уже открыто на строке &3."
                                        , p-q-name
                                        , p-q-name
                                        , buf_rec-fld-list.fldOpenLine
                                        )
                    ).
                end.        /* if buf_rec-fld-list.closed = no */
                else do:        /* Незакрытого поля с этим именем нет. Можно открывать. */
                    run xmllib-parse-rec-fld-open in this-procedure (
                          input buf_rec-list.recName
                        , input buf_rec-list.recLevel
                        , input buf_rec-fld-list.fldName
                    ).
                    assign
                        buf_rec-fld-list.closed         = no
                        buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                        buf_rec-fld-list.fldCloseLine   = 0
                    .
                end.        /* NOT ( if buf_rec-fld-list.closed = no ) */
            end.        /* if available buf_rec-fld-list */
            else do:
                assign
                    buf_rec-list.recLevel = buf_rec-list.recLevel + 1
                .
                run xmllib-parse-rec-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                ).
                assign
                    buf_rec-list.closed         = no
                    buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-list.recCloseLine   = 0
                .
/*                run xmllib-parse-error in this-procedure (*/
/*                    input substitute( "Ошибка 1 открытия записи <&1>: Запись с этим именем уже открыта на строке &2."*/
/*                                    , p-q-name*/
/*                                    , buf_rec-list.recOpenLine*/
/*                                    )*/
/*                ).*/
            end.        /* NOT ( if available buf_rec-fld-list ) */
        end.        /* if buf_rec-list.closed = no */
        else do:        /* Запись закрыта. Можно создавать новую запись. */
            run xmllib-parse-rec-open in this-procedure (
                  input buf_rec-list.recName
                , input buf_rec-list.recLevel
            ).
            assign
                buf_rec-list.closed         = no
                buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                buf_rec-list.recCloseLine   = 0
            .
        end.        /* NOT ( if buf_rec-list.closed = no ) */
    end.        /* if available buf_rec-list */
    else do:        /* Имени тэга нет в списке записей, но оно, возможно, есть в списке полей. */
        open-record:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName = buf_rec-fld-list.recName
                   and buf_rec-list.closed  = no
            no-error.
            if available buf_rec-list
            then do:        /* Нашли запись, в которой определено это поле. Если такой нет - ничего не выводить. */
                run xmllib-parse-rec-fld-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                    , input buf_rec-fld-list.fldName
                ).
                assign
                    buf_rec-fld-list.recLevel       = buf_rec-list.recLevel
                    buf_rec-fld-list.closed         = no
                    buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-fld-list.fldCloseLine   = 0
                .
                leave open-record.
            end.
        end.
    end.        /* NOT ( if available buf_rec-list ) */
end.
end procedure. /* StartElement */


/*==========================================================================*/
procedure Characters :
define input parameter p-char-data  as memptr.
define input parameter p-numchars   as integer.

    define variable v-data-string    as character    no-undo.

    define variable v-cp-utf8           as integer no-undo init 65001 .
    define variable v-cp-windows1251    as integer no-undo init 1251 .

    define buffer buf_xmllib_rec             for temp_xmllib_rec.
    define buffer buf_xmllib_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_xmllib_rec-list        for temp_xmllib_rec-list.
    define buffer buf_xmllib_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_xmllib_rec
  , buf_xmllib_rec-fld
  , buf_xmllib_rec-list
  , buf_xmllib_rec-fld-list
on error undo, return error
:

    find first buf_xmllib_rec-list
         where buf_xmllib_rec-list.closed = no
    no-error.
    if available buf_xmllib_rec-list
    then do:
        find first buf_xmllib_rec-fld-list
             where buf_xmllib_rec-fld-list.closed = no
        no-error.
        if available buf_xmllib_rec-fld-list
        and buf_xmllib_rec-fld-list.recName  = buf_xmllib_rec-list.recName
        and buf_xmllib_rec-fld-list.recLevel = buf_xmllib_rec-list.recLevel
        then do:
            find last buf_xmllib_rec
                where buf_xmllib_rec.recName  = buf_xmllib_rec-list.recName
                  and buf_xmllib_rec.recLevel = buf_xmllib_rec-list.recLevel
                  and buf_xmllib_rec.closed   = no
            use-index nm
            no-error.
            if available buf_xmllib_rec
            then do:
                find last buf_xmllib_rec-fld
                    where buf_xmllib_rec-fld.rec-key = buf_xmllib_rec.rec-key
                      and buf_xmllib_rec-fld.fldName = buf_xmllib_rec-fld-list.fldName
                      and buf_xmllib_rec-fld.closed = no
                use-index nm
                no-error.
                if available buf_xmllib_rec-fld
                then do:
                    assign
                        v-data-string = get-string( p-char-data, 1, get-size( p-char-data ) )
                    .
                    if v-xmllib-codepage-convert = yes
                    then do:
                      assign
                          v-data-string = codepage-convert( v-data-string , v-xmllib-codepage-target , v-xmllib-codepage-source )
                      .
                    end.
                    run xmlchar-decode in this-procedure (
                        input v-data-string
                        , output v-data-string
                    ).
                    assign
                        buf_xmllib_rec-fld.fldValue = trim( substitute( "&1&2", buf_xmllib_rec-fld.fldValue, v-data-string ) )
                    .
                end.        /* if available buf_rec-fld */
            end.        /* if available buf_xmllib_rec */
        end.        /* if available buf_rec-fld-list */
    end.        /* if available buf_rec-list */
end.
end procedure. /* Characters */


/*==========================================================================*/
procedure EndElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.

    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find last buf_rec-list
        where buf_rec-list.recName = p-q-name
    use-index pi
    no-error.
    if available buf_rec-list
    then do:
        if buf_rec-list.closed = yes
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка закрытия записи или поля <&1>: Нет метки открытой записи."
                                , p-q-name
                                )
            ).
        end.        /* if buf_rec-list.closed = yes */
        else do:
            find last buf_rec
                where buf_rec.recName  = buf_rec-list.recName
                  and buf_rec.recLevel = buf_rec-list.recLevel
                  and buf_rec.closed   = no
            use-index nm
            no-error.
            if not available buf_rec
            then do:
                run xmllib-parse-error in this-procedure (
                    input substitute( "Ошибка закрытия записи или поля <&1> уровня &2: Нет открытой записи."
                                    , p-q-name
                                    , buf_rec-list.recLevel
                                    )
                ).
            end.        /* if not available buf_rec */
            else do:        /* Есть метка открытой записи, и есть открытая запись с тем же именем, что у метки. */
                find first buf_rec-fld-list
                     where buf_rec-fld-list.recName  = buf_rec.recName
                       and buf_rec-fld-list.recLevel = buf_rec.recLevel
                       and buf_rec-fld-list.fldName  = p-q-name
                       and buf_rec-fld-list.closed   = no
                no-error.
                if not available buf_rec-fld-list
                then do:        /* Нет метки открытого поля с таким именем */
                    if buf_rec.recName <> p-q-name
                    then do:        /* Имя открытой записи не совпадает с именем закрываемого тэга. */
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка закрытия записи <&1>: Имя открытой записи не совпадает с именем метки."
                                            , buf_rec.recName
                                            )
                        ).
                    end.        /* if buf_rec.recName <> p-q-name */
                    else do:        /* Имя открытой записи совпадает с именем тэга */
                        assign
                            buf_rec.closed              = yes
                            buf_rec.recCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-list.recCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                        if buf_rec-list.recLevel > 0
                        then do:
                            assign
                                buf_rec-list.recLevel = buf_rec-list.recLevel - 1
                            .
                            for each buf_rec-fld-list
                               where buf_rec-fld-list.recName = buf_rec-list.recName
                            :
                                assign
                                    buf_rec-fld-list.recLevel = buf_rec-fld-list.recLevel - 1
                                .
                            end.
                        end.
                        else do:
                            assign
                                buf_rec-list.closed         = yes
                            .
                        end.
                    end.        /* NOT ( if buf_rec.recName <> buf_rec-fld-list.recName  ) */
                end.
                else do:        /* Открыто поле с таким именем */
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 2 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.        /* if not available buf_rec-fld */
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.        /* NOT ( if not available buf_rec-fld ) */
                end.
            end.        /* NOT ( if not available buf_rec ) */
        end.        /* NOT ( if buf_rec-list.closed = yes ) */
    end.        /* if available buf_rec-list */
    else do:
        close-field-rec:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName  = buf_rec-fld-list.recName
                   and buf_rec-list.recLevel = buf_rec-fld-list.recLevel
                   and buf_rec-list.closed   = no
            no-error.
            if available buf_rec-list
            then do:
                find last buf_rec
                    where buf_rec.recName  = buf_rec-list.recName
                      and buf_rec.recLevel = buf_rec-list.recLevel
                      and buf_rec.closed   = no
                use-index nm
                no-error.
                if not available buf_rec
                then do:
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка закрытия поля <&1>: Нет открытой записи."
                                        , p-q-name
                                        )
                    ).
                end.        /* if not available buf_rec */
                else do:        /* Есть метка открытой записи, и есть открытая запись с тем же именем, что у метки. */
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 1 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.        /* if not available buf_rec-fld */
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.        /* NOT ( if not available buf_rec-fld ) */
                end.
                leave close-field-rec.
            end.
        end.
    end.        /* NOT ( if available buf_rec-fld-list ) */
end.
end procedure. /* EndElement */


/*==========================================================================*/
procedure Error :
define input parameter p-error-message     as character        no-undo.
do
on error undo, return error
:
    run xmllib-parse-error in this-procedure (
        input p-error-message
    ).
    assign
        v-xmllib-error-status = yes
    .
end.
end procedure. /* Error */


/*==========================================================================*/
procedure xmllib-parse-error :
define input parameter p-err-message    as character        no-undo.

do
on error undo, return error
:
    if valid-handle(v-xmllib-log-handle) then do:
      run value(v-xmllib-log-proc-name) in  v-xmllib-log-handle
               (input substitute("&1Файл:    &2 &3&1Строка &4&1&5"
                                 ,{&new-line}
                                 ,v-xmllib-dirname
                                 ,v-xmllib-filename
                                 ,(if valid-handle(v-xmllib-sax-reader-handle)
                                   then v-xmllib-sax-reader-handle :locator-line-number
                                   else ?)
                                 ,p-err-message)).
    end.
    else do:
      if v-xmllib-log-filename = "":U
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip "Файл:   " v-xmllib-dirname v-xmllib-filename
              skip "Строка: " (if valid-handle(v-xmllib-sax-reader-handle)
                               then v-xmllib-sax-reader-handle :locator-line-number
                               else ?)
              skip(1)
              skip p-err-message
              skip return-value
              skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
          view-as alert-box error.
          undo, return error.
      end.
      else do:
        output to value( v-xmllib-log-filename ).
        put unformatted
            substitute( "&1&2", {&new-line}, p-err-message )
        .
        output close.

      end.
    end.
end.
end procedure. /* xmllib-parse-error */




/*==========================================================================*/
procedure xmllib-set-log-filename :
define input parameter p-log-filename   as character        no-undo.

do
on error undo, return error
:
    run gbl/fileapnd.p (
          input p-log-filename
        , input "":U
        , input 10
    ) no-error.
    if error-status :error
    then do:
        assign
            v-xmllib-log-filename = "":U
        .
    end.
    else do:
        assign
            v-xmllib-log-filename = p-log-filename
        .
    end.
end.
end procedure. /* xmllib-set-log-filename */

/*==========================================================================*/
procedure xmllib-set-log-handle :
define input parameter p-log-handle    as handle        no-undo.
define input parameter p-log-proc-name as character no-undo .

do
on error undo, return error
:
    if valid-handle(p-log-handle)
    and lookup(p-log-proc-name, p-log-handle:internal-entries) > 0
    then do:
      assign
      v-xmllib-log-handle    = p-log-handle
      v-xmllib-log-proc-name = p-log-proc-name
      .
    end.
    else do:
      assign
      v-xmllib-log-handle    = ?
      v-xmllib-log-proc-name = '':U
      .
    end.
end.
end procedure. /* xmllib-set-log-handle */

/*==========================================================================*/
procedure xmllib-set-prg-bar-handle :
define input parameter p-handle    as handle        no-undo.

do
on error undo, return error
:
    if valid-handle(p-handle)
    then do:
      assign
        v-xmllib-prg-bar-handle = p-handle
      .
    end.
    else do:
      assign
        v-xmllib-prg-bar-handle = ?
      .
    end.
end.
end procedure. /* xmllib-set-prg-bar-handle */

/*==========================================================================*/
procedure xmllib-set-codepage-convert :
  define input  parameter p-codepage-source as character no-undo .
  define input  parameter p-codepage-target as character no-undo .
do
on error undo, return error return-value
:
  if ( p-codepage-source <> "" and p-codepage-target <> "" )
  then do:
    assign
      v-xmllib-codepage-convert = yes
      v-xmllib-codepage-source  = p-codepage-source
      v-xmllib-codepage-target  = p-codepage-target
    .
  end.
  else do:
    assign
      v-xmllib-codepage-convert = no
      v-xmllib-codepage-source  = ""
      v-xmllib-codepage-target  = ""
    .
  end.
end.

end procedure. /* xmllib-set-codepage-convert */

/*==========================================================================*/
procedure xmllib-parse-rec-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.

    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
do
for buf_temp_xmllib_rec
on error undo, return error
:
     find first buf_temp_xmllib_rec
         where buf_temp_xmllib_rec.recName = p-rec-name
           and buf_temp_xmllib_rec.recLevel = p-rec-level
           and buf_temp_xmllib_rec.closed  = no
    use-index nm
    no-error.
    if available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия записи <&1>: Запись с этим именем и уровнем &2 уже открыта на строке &3."
                            , p-rec-name
                            , p-rec-level
                            , buf_temp_xmllib_rec.recOpenLine
                            )
        ).
    end.        /* if available buf_temp_xmllib_rec  */
    else do:
        assign
            v-xmllib-rec-key    = v-xmllib-rec-key + 1
        .
        create buf_temp_xmllib_rec.
        assign
            buf_temp_xmllib_rec.rec-key         = v-xmllib-rec-key
            buf_temp_xmllib_rec.recOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
            buf_temp_xmllib_rec.recCloseLine    = 0
            buf_temp_xmllib_rec.recName         = p-rec-name
            buf_temp_xmllib_rec.recLevel        = p-rec-level
            buf_temp_xmllib_rec.closed          = no
        .
    end.        /* NOT ( if available buf_temp_xmllib_rec  ) */
end.
end procedure. /* xmllib-parse-rec-open */


/*==========================================================================*/
procedure xmllib-parse-rec-fld-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.
define input parameter p-fld-name   as character        no-undo.

    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
    define buffer buf_temp_xmllib_rec-fld   for temp_xmllib_rec-fld.
do
for buf_temp_xmllib_rec
  , buf_temp_xmllib_rec-fld
on error undo, return error substitute( "Ошибка в xmllib-parse-rec-fld-open. &1. &2. &3"
                                        , return-value
                                        , trim( error-status :get-message( 1 ) )
                                        , trim( error-status :get-message( 2 ) ) )
:
    find last buf_temp_xmllib_rec
        where buf_temp_xmllib_rec.recName   = p-rec-name
          and buf_temp_xmllib_rec.recLevel  = p-rec-level
          and buf_temp_xmllib_rec.closed    = no
    use-index nm
    no-error.
    if not available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия поля <&2> в записи <&1> уровня &3: Нет открытой записи."
                            , p-rec-name
                            , p-fld-name
                            , p-rec-level
                            )
        ).
    end.        /* if not available buf_temp_xmllib_rec */
    else do:
        find last buf_temp_xmllib_rec-fld
            where buf_temp_xmllib_rec-fld.rec-key  = buf_temp_xmllib_rec.rec-key
              and buf_temp_xmllib_rec-fld.fldName  = p-fld-name
              and buf_temp_xmllib_rec-fld.closed   = no
        use-index nm
        no-error.
        if available buf_temp_xmllib_rec-fld
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка 3 открытия поля <&2> в записи <&1>: Поле с этим именем уже открыто на строке &3."
                                , p-rec-name
                                , p-fld-name
                                , buf_temp_xmllib_rec-fld.fldOpenLine
                                )
            ).
        end.        /* if available buf_temp_xmllib_rec  */
        else do:
            assign
                v-xmllib-rec-fld-key    = v-xmllib-rec-fld-key + 1
            .
            create buf_temp_xmllib_rec-fld.
            assign
                buf_temp_xmllib_rec-fld.fld-key         = v-xmllib-rec-fld-key
                buf_temp_xmllib_rec-fld.rec-key         = buf_temp_xmllib_rec.rec-key
                buf_temp_xmllib_rec-fld.fldOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
                buf_temp_xmllib_rec-fld.fldCloseLine    = 0
                buf_temp_xmllib_rec-fld.fldName         = p-fld-name
                buf_temp_xmllib_rec-fld.closed          = no
            .
        end.        /* NOT ( if available buf_temp_xmllib_rec  ) */
    end.        /* NOT ( if not available buf_temp_xmllib_rec ) */
end.
end procedure. /* xmllib-parse-rec-fld-open */