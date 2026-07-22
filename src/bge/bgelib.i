/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для работы с форматом XML и выводом в LOG и EDItor

Автор: Хныкин Павел Андреевич
Дата создания: 09/09/05
Author: Pavel Khnykin
Creation date: 09/09/05

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&scoped-define Tabspaces 4
&scoped-define LogLineSize 80
&scoped-define ScnFileName 'bgescn.txt'

&global-define bge-xml_shedule-out-dir bge-xml_shedule-out-dir
&global-define bge-xml_shedule-parameters bge-xml_shedule-parameters
&global-define bge-xml_shedule-obj-list bge-xml_shedule-obj-list

&global-define bgelib_minimum-free-mbytes 200       /* Минимальное свободное место на диске */
&global-define bgelib-check-freespace-size 1048576  /* Для частоты проверки на свободное место, в байтах */
&global-define bgelib_maximum-file-size 100         /* Размер файла выгрузки, по достижению которого выгружается текущая операция и открывается новый файл. */
&global-define bgelib-temp-extension "tmp"          /* Расширение временного файла */

define variable v-bgelib-bgefmt        as character         no-undo.       /* Формат вывода (xml, dbf) */
define variable v-bgelib-bgeflold      as character         no-undo.       /* Вариант создания файлов (old, var, new, firm) */

define stream stmXMLOut.
define stream stmXMLLog.

{ gbl/cur-time.i }
{ gbl/xmlchar.i  }

define variable v-bgelib-bgeclall           as logical      no-undo.        /* Справочник клиентов экспортировать полностью */
define variable v-bgelib-bgedict            as logical      no-undo.        /* Экспортировать справочники дисконтных карт, типов платежа и кассовых кодов оплат */

define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character

    index pi is primary unique
        edt-key
.
define temp-table temp_bgelib_goods no-undo
    field gds-code as integer

    index pi is primary unique
        gds-code
.
define temp-table temp_bgelib_clients no-undo
    field obj-type as character
    field obj-code as integer

    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bgelib_dis-card no-undo
    field d-card as character

    index pi is primary unique
        d-card
.
define temp-table temp_bgelib_trn-doc no-undo
    field doc-code as integer
.
/*========================================================================*/
/*
    Процедура открывает тэг
    input:
        v-tag-level         - условный уровень тэга ( количество пробелов от начала файла * {&Tabspaces} )
        v-tag-name          - имя тэга
        v-tag-value         - значение тэга,
                              можно передавать и значения типа 'Адрес="ул. Салтыкова"'
*/
procedure bgelib-tag-open:
do
on error undo, return error
:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.

/*    run xmlchar-encode in this-procedure (*/
/*          input v-tag-value*/
/*        , output v-tag-value*/
/*    ).*/
    put stream stmXMLOut unformatted
        {&new-line}
        + fill(" ", {&Tabspaces} * v-tag-level)
        + "<" + v-tag-name
        + ( if v-tag-value = "" or v-tag-value = ? then "" else " " )
        + v-tag-value + ">"
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
procedure bgelib-tag-put:
do
on error undo, return error
:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
    v-tag-name = trim(v-tag-name).
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "" and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "" and v-tag-value <> ? and v-tag-value <> "0"))
    or (v-empty-mode = 3 and (v-tag-value <> "" and v-tag-value <> ? and caps(v-tag-value) <> "no"))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            {&new-line} + fill(" ", {&Tabspaces} * v-tag-level)
                        + '<' + v-tag-name + '>'
                        + v-tag-value
                        + '</' + v-tag-name + '>'
        .
    end.
end.
end procedure.

/*========================================================================*/
/*  Процедура закрывает тэг

    input:
        v-tag-level - условный уровень тэга (количество пробелов от начала файла * {&Tabspaces})
        v-tag-name  - имя тэга
*/
procedure bgelib-tag-close:
do
on error undo, return error
:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.

    put stream stmXMLOut unformatted
        {&new-line}
        + fill( " ", {&Tabspaces} * v-tag-level)
        + '</' + v-tag-name + '>'
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
procedure bgelib-write-log:
do
on error undo, return error
:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.

    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        {&new-line}
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine"
          or v-out-string = "&Line"
          then ""
          else cur-time-string-sec() + " " )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line"
          then fill( "-", {&LogLineSize} )
          else if v-out-string = "&DLine"
               then fill( "=", {&LogLineSize} )
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
procedure bgelib-write-edt:
do
on error undo, return error
:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.

    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine"
                                          or v-out-string = "&Line"
                                          then ""
                                          else cur-time-string-sec() + " "
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line"
                                          then fill( "-", {&LogLineSize} )
                                          else if v-out-string = "&DLine" then fill("=", {&LogLineSize})
                                          else fill( " ", v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( {&new-line} ).
    end.
    process events.
    output to {&ScnFileName} append.
        put unformatted
            {&new-line}
            string( ( if v-log-level = 0
                      or v-out-string = "&DLine"
                      or v-out-string = "&Line"
                      then ""
                      else string( today ) + " " + string( time, "hh:mm:ss" ) + " "
                  ) )
            string( ( if v-out-string = "&Line"
                      then fill( "-", {&LogLineSize} )
                      else if v-out-string = "&DLine"
                           then fill( "=", {&LogLineSize} )
                           else fill( " ", v-log-level ) + v-out-string
                  ) )
        .
    output close.
end.
end procedure.

/*========================================================================*/
/*
    Процедура делает видимым fill-in, определенный параметром v-fillin-handle.
*/
procedure bgelib-show-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.

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
procedure bgelib-hide-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.

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
procedure bgelib-write-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.

    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.

/*========================================================================*/
procedure bgelib-write-header:
do
on error undo, return error
:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter p-doc-type-list  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.

    define variable v-counter    as integer        no-undo.

    output stream stmXMLOut to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run bgelib-tag-open( input 0, input "root"  , input "" ).
    run bgelib-tag-open( input 0, input "header", input "" ).
    run bgelib-tag-put( input 1, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 1, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 1, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 1, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 1, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 1, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run bgelib-tag-close( input 0, input "header" ).
    output stream stmXMLOut close.

    output stream stmXMLOut to value( p-list-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    if p-first-file = yes
    then do:
        put stream stmXMLOut unformatted
            "<?xml version='1.0' encoding='windows-1251'?>"
        .
        run bgelib-tag-open( input 0, input "export", input "" ).
    end.
    run bgelib-tag-open( input 1, input "file", input "" ).
    run bgelib-tag-put( input 2, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 2, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 2, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 2, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 2, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 2, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 2
            , input trim(entry( 2 * v-counter, p-parameter-list ))
            , input trim(entry( 2 * v-counter + 1, p-parameter-list ))
            , input 0
        ).
    end.
    run bgelib-tag-close( input 1, input "file" ).
    output stream stmXMLOut close.
end.
end procedure.

/*========================================================================*/
/*
    Процедура закрывает тэг root, переименовывает временный файл в .xml
*/
procedure bgelib-write-footer:
do
on error undo, return error
:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.

    define variable v-error-num     as integer           no-undo.

    output stream stmXMLOut to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run bgelib-tag-open( input 0, input "footer", "" ).
        run bgelib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run bgelib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run bgelib-tag-close( input 0, input "footer" ).
    end.
    run bgelib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    /*- переименовать: .tmp -> .xml -*/
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + {&bgelib-temp-extension}
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    then do:
        output stream stmXMLOut to value( p-list-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
            run bgelib-tag-close( input 0, input "export" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + {&bgelib-temp-extension}
            , input p-list-file-name + "xml"
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
procedure bgelib-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.

    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.

    get-key-value section "BGE" key "outdir" value v-home-dir.
    if v-home-dir = ?
    then do:            /* нет ключа */
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
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
        , input {&bgelib-temp-extension}
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + {&back-slash-char} + "actions.log"
        p-list-file-name    = v-home-dir + {&back-slash-char} + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure. /* bgelib-log-filename */

/*==========================================================================*/
/*
    Чтение параметров для выгрузки
*/
procedure bgelib-read-config :
do
on error undo, return error
:
define variable v-par-type as character     no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .


    assign
        v-bgelib-bgeclall = no
        v-bgelib-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeclall}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeclall = no
      .
    end.
    else do:
      assign
        v-bgelib-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgedict}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgedict = no
      .
    end.
    else do:
      assign
        v-bgelib-bgedict = v-value-logical
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgefmt}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bgelib-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.

    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  {&attr-bge-export}
                      , input  {&attr-bge-export_bgeflold}
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgelib-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.

end.
end procedure. /* bgelib-read-config */


/*==========================================================================*/
procedure bgelib-check-file-size :
do
on error undo, return error
:
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.

    define variable v-current-position    as integer        no-undo.

    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= {&bgelib_maximum-file-size}
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure. /* bgelib-check-space-and-file */

/*==========================================================================*/
procedure bgelib-init-ext-doc-type :

    define variable v-counter    as integer      no-undo.

    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( {&TDEDT_List} )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, {&TDEDT_List} )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, {&TDEDT_List-full} )
        .
    end.        /* do */
end.
end procedure. /* bge-xml-init-ext-doc-type */