block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oxmlouta.p $
$Archive: bge/oxmlouta.p $

Начальный экспорт в файл OpenXML

Автор: Хныкин Павел Андреевич
Дата создания: 08/16/06
Author: Pavel Khnykin
Creation date: 08/16/06

Input:
    p-mainmenu-handle     - handle главного окна
    p-parent-handle       - handle вызывающей процедуры
    p-log-handle          - handle для записи лога (в handl-е должна быть поцедура write-log)
    p-parameter-string    - Строка параметров, через запятую. Первый параметр должен быть номером БД.

Output:

*/
define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-parent-handle      as widget-handle    no-undo.
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-parameter-string   as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlouta.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlouta.p $":U .
define variable vss-description as character no-undo init "Начальный экспорт в файл OpenXML".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/xmlchar.i  }
{ str/xmllib.i   }

define stream out-stream.

define temp-table temp_table no-undo
    field dtt-name  as character
    field dtt-tag   as character

    index pi is primary unique
        dtt-name
.
define temp-table temp_table-field no-undo
    field dtt-name  as character
    field dtf-name  as character
    field dtf-tag   as character

    index pi is primary unique
        dtt-name
        dtf-name
.

    define variable v-cur-db-num        as integer      no-undo.
    define variable v-esys-id           as integer      no-undo.
    define variable v-db-num            as integer      no-undo.
    define variable v-buffer-handle     as handle       no-undo.
    define variable v-xml-file-name     as character    no-undo.
    define variable v-log-file-name     as character    no-undo.
    define variable v-list-file-name    as character    no-undo.
    define variable v-tesr-key          as integer      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-parameter-list    as character    no-undo.
    define variable v-action            as character    no-undo.

    define buffer buf_ext-system                for ub.ext-system.
    define buffer buf_esys-datatype-exp         for ub.esys-datatype-exp.
    define buffer buf_datatype-exp              for ub.datatype-exp.
    define buffer buf_datatype-table-exp        for ub.datatype-table-exp.
    define buffer buf_datatype-table-field-exp  for ub.datatype-table-field-exp.
    define buffer buf_temp_table                for temp_table.
    define buffer buf_temp_table-field          for temp_table-field.
    define buffer buf_datatype-table            for ub.datatype-table.
    define buffer buf_datatype-table-field      for ub.datatype-table-field.
do
for buf_ext-system
  , buf_esys-datatype-exp
  , buf_datatype-exp
  , buf_datatype-table-exp
  , buf_datatype-table-field-exp
  , buf_temp_table
  , buf_temp_table-field
  , buf_datatype-table
  , buf_datatype-table-field
on error undo, return error
:
    assign
        v-cur-db-num = integer( entry( 1, p-parameter-string ) )
        v-esys-id    = integer( entry( 2, p-parameter-string ) )
        v-db-num     = integer( entry( 3, p-parameter-string ) )
    .
    find first buf_ext-system no-lock
         where buf_ext-system.esys-id = v-esys-id
           and buf_ext-system.db-num  = v-db-num
    no-error.
    if available buf_ext-system
    then do:
        if buf_ext-system.esys-have-export = yes
        and buf_ext-system.esys-status     <> 0
        then do:
            run write-log in p-log-handle (
                  input 1
                , input substitute( "Выгрузка данных по внешней системе '&1'... ", buf_ext-system.esys-name )
            ).
            run xmllib-filename in this-procedure (
                  input "":U
                , input "o":U
                , output v-xml-file-name
                , output v-log-file-name
                , output v-list-file-name
            ).
            assign
                v-list-file-name = "":U
                v-parameter-list = substitute( "&1,&2,&3,&4,&5,&6,&7"
                                                , 5
                                                , "format":U
                                                , "Trade House OpenXML 1.0":U
                                                , "version":U
                                                , trim( replace( substring( vss-archive, 15, 4 ), "$":U, "":U ) )
                                                , "revision":U
                                                , trim( replace( substring( vss-revision, 12 ), "$":U, "":U ) )
                                            )
                v-parameter-list = substitute( "&1,&2,&3,&4,&5"
                                                , v-parameter-list
                                                , "esysName":U
                                                , buf_ext-system.esys-name
                                                , "currentDbNum":U
                                                , string( v-cur-db-num )
                                            )
            .
            run xmllib-write-header in this-procedure (
                  input yes
                , input v-xml-file-name
                , input v-list-file-name
                , input 1
                , input no
                , input "":U
                , input v-parameter-list
            ).
            for each buf_esys-datatype-exp no-lock
               where buf_esys-datatype-exp.esys-id      = buf_ext-system.esys-id
                 and buf_esys-datatype-exp.db-num       = buf_ext-system.db-num
                 and buf_esys-datatype-exp.ede-status   <> 0
            on error undo, return error
            :
                find first buf_datatype-exp no-lock
                     where buf_datatype-exp.dte-id = buf_esys-datatype-exp.dte-id
                no-error.
                if available buf_datatype-exp
                and buf_datatype-exp.dte-status <> 0
                then do:
                    for each buf_datatype-table-exp no-lock
                       where buf_datatype-table-exp.dte-id      = buf_datatype-exp.dte-id
                         and buf_datatype-table-exp.dtte-status <> 0
                    on error undo, return error
                    :
                        find first buf_temp_table
                             where buf_temp_table.dtt-name = buf_datatype-table-exp.dtt-name
                        no-error.
                        if not available buf_temp_table
                        then do:
                            find first buf_datatype-table no-lock
                                 where buf_datatype-table.dtt-name = buf_datatype-table-exp.dtt-name
                            no-error.
                            create buf_temp_table.
                            assign
                                buf_temp_table.dtt-name = buf_datatype-table-exp.dtt-name
                                buf_temp_table.dtt-tag  = ( if available buf_datatype-table
                                                            then buf_datatype-table.dtt-xml-tag
                                                            else "TH_" + buf_datatype-table-exp.dtt-name )
                            .
                        end.
                        for each buf_datatype-table-field-exp no-lock
                           where buf_datatype-table-field-exp.dte-id    = buf_datatype-table-exp.dte-id
                             and buf_datatype-table-field-exp.dtt-name  = buf_datatype-table-exp.dtt-name
                        on error undo, return error
                        :
                            find first buf_temp_table-field
                                 where buf_temp_table-field.dtt-name = buf_datatype-table-field-exp.dtt-name
                                   and buf_temp_table-field.dtf-name = buf_datatype-table-field-exp.dtf-name
                            no-error.
                            if not available buf_temp_table-field
                            then do:
                                find first buf_datatype-table-field no-lock
                                     where buf_datatype-table-field.dtt-name = buf_datatype-table-field-exp.dtt-name
                                       and buf_datatype-table-field.dtf-name = buf_datatype-table-field-exp.dtf-name
                                no-error.
                                create buf_temp_table-field.
                                assign
                                    buf_temp_table-field.dtt-name = buf_datatype-table-field-exp.dtt-name
                                    buf_temp_table-field.dtf-name = buf_datatype-table-field-exp.dtf-name
                                    buf_temp_table-field.dtf-tag  = ( if available buf_datatype-table-field
                                                                      then buf_datatype-table-field.dtf-xml-tag
                                                                      else "TH_" + buf_datatype-table-field-exp.dtf-name )
                                .
                            end.
                        end.        /* for each buf_datatype-table-field-exp */
                    end.        /* for each buf_datatype-table-exp */
                end.
            end.        /* for each buf_esys-datatype-exp */
            OUTPUT STREAM stmXMLOut TO VALUE( v-xml-file-name + {&xmllib-temp-extension} ) CONVERT TARGET "1251" APPEND.
            run export-tables in this-procedure .
            OUTPUT STREAM stmXMLOut close.
            run xmllib-write-footer in this-procedure (
                  input yes
                , input v-xml-file-name
                , input v-list-file-name
                , input no
                , input "":U
            ).
            run write-log in p-log-handle (
                  input 1
                , input substitute( "Выгрузка данных по внешней системе '&1' завершена. ", buf_ext-system.esys-name )
            ).
        end.
    end.
end.

/*==========================================================================*/
procedure export-tables :

    define variable v-bh            as handle       no-undo.
    define variable v-qh            as handle       no-undo.
    define variable v-query         as character    no-undo.
    define variable v-buffer-name   as character    no-undo.

    define buffer buf_temp_table                for temp_table.
    define buffer buf_temp_table-field          for temp_table-field.
do
for buf_temp_table
  , buf_temp_table-field
on error undo, return error
:
    for each buf_temp_table
    on error undo, return error
    :       /* Экспорт всех данных таблицы*/
        run xmllib-tag-open in this-procedure ( input 1, input buf_temp_table.dtt-tag, input "":U ).
        run xmllib-tag-put in this-procedure ( input 2, input "TH__record-action"    , input "export":U    , input 0 ).
/*        run xmllib-tag-put in this-procedure ( input 2, input "TH__record-unique-key"   , input p-unique-key, input 0 ).*/
        assign
            v-buffer-name = "buf_" + buf_temp_table.dtt-name
        .
        create buffer v-bh for table buf_temp_table.dtt-name buffer-name v-buffer-name.
        create query v-qh.
        v-qh :set-buffers( v-bh ).
        assign
            v-query             = substitute( "for each &1 no-lock"
                                                , v-buffer-name )
        .
        v-qh :query-prepare( v-query ).
        v-qh :query-open.
        v-qh :get-first.
        if v-qh :query-off-end = no
        then do:
            export-table:
            do
            while yes
            on error undo, return error
            :
                v-qh :get-next.
                if v-qh :query-off-end = yes
                then do:
                    undo export-table, leave export-table.
                end.
                for each buf_temp_table-field
                on error undo, return error
                :
                    run xmllib-tag-put in this-procedure (
                          input 2
                        , input buf_temp_table-field.dtf-tag
                        , input v-bh :buffer-field( buf_temp_table-field.dtf-name ) :buffer-value
                        , input 0
                    ).
                end.        /* for each buf_temp_table-field */
            end.
        end.        /* if qh :query-off-end = no */
        delete object v-qh.
        delete object v-bh.
        run xmllib-tag-close in this-procedure ( input 1, input buf_temp_table.dtt-tag ).
    end.        /* for each buf_temp_table */
end.
end procedure. /* export-tables */