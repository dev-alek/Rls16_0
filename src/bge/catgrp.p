block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: catgrp.p $
$Archive: bge/catgrp.p $

Экспорт структуры групп товаров

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:

Output:

*/
define input parameter p-grp-amount    as integer      no-undo.
define input parameter p-grp-code-list as character    no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$date: 12.08.03 16:43 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: catgrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/catgrp.p $":U .
define variable vss-description as character no-undo init "Экспорт структуры групп товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bgelib.i   }

&scoped-define version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 4

do
on error undo, return error
:
    define variable v-counter       as inT      inIT 0      no-undo. /* счетчик для цикла */
    define variable v-xml-file-name     as character     no-undo.
    define variable v-log-file-name     as character     no-undo.
    define variable v-list-file-name    as character     no-undo.
    define variable v-xml-file-number   as integer       no-undo.
    define variable v-cancel            as logical       no-undo.
    define variable v-parameter-list    as character     no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.

    run bgelib-filename in this-procedure (
          input "grp"
        , output v-xml-file-name
        , output v-log-file-name
        , output v-list-file-name
    ).
    run gbl/waitfrsp.w (
          input substring( v-xml-file-name, 1, 1 )
        , input {&bgelib_minimum-free-mbytes}
        , output v-cancel
    ) .
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки справочника групп товаров в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    if p-grp-amount = ?
    or p-grp-code-list = ?
    or ( p-grp-amount <> 0
         and num-entries( p-grp-code-list ) = 0 )
    then do:
        run bgelib-write-log in this-procedure (
              input v-log-file-name
            , input 1
            , input "Неверно заданы входные параметры."
        ).
        undo, return error.
    end.
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "gdsgrp":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
        v-xml-file-number       =   1
    .
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input v-xml-file-number                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input ""
        , input ""
        , input v-parameter-list
    ).
    if p-grp-amount = 0
    then do:
        for each buf_gds-grp no-lock
        by buf_gds-grp.node-code
        :
            run export-group(
                  input buf_gds-grp.node-code
                , input v-parameter-list
                , input v-xml-file-name
                , input v-log-file-name
                , input v-list-file-name
                , input v-xml-file-number
                , output v-xml-file-name
                , output v-xml-file-number
            ).
        end.
    end.
    else do:
            do v-counter = 1 to ( num-entries( p-grp-code-list ) )
            :
                run export-group(
                      input integer( entry( v-counter, p-grp-code-list ) )
                    , input v-parameter-list
                    , input v-xml-file-name
                    , input v-log-file-name
                    , input v-list-file-name
                    , input v-xml-file-number
                    , output v-xml-file-name
                    , output v-xml-file-number
                ).
            end.
    end.
    run bgelib-write-footer in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input no
        , input ""
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xml"
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
end.
/*========================================================================*/
procedure export-group:
do
on error undo, return error
:
define input parameter p-node-code    as integer no-undo.
define input parameter p-parameter-list         as character    no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-last-xml-file-name    as character    no-undo.
define output parameter p-last-xml-file-number  as integer      no-undo.

    define variable v-need-new-file as logical      no-undo.
    define variable v-void-string   as character      no-undo.
    define variable v-prev-filename as character      no-undo.

    define buffer buf_gds-grp for ub.gds-grp.

    assign
        p-last-xml-file-name   = p-xml-file-name
        p-last-xml-file-number = p-xml-file-number
    .
    run bgelib-check-file-size in this-procedure (
          input p-xml-file-name + {&bgelib-temp-extension}
        , output v-need-new-file
    ).
    if v-need-new-file = yes
    then do:
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "grp"
            , output p-xml-file-name
            , output v-void-string
            , output v-void-string
        ).
        run bgelib-write-footer in this-procedure (
              input no
            , input v-prev-filename
            , input p-list-file-name
            , input yes
            , input p-xml-file-name + "xml":U
        ).
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "Данные выгружены в файл &1"
                                    , replace( p-xml-file-name, "/", "\" ) + "xml"
                            )
        ).
        assign
            p-last-xml-file-number   = p-xml-file-number + 1
            p-last-xml-file-name     = p-xml-file-name
        .
        run bgelib-write-header in this-procedure (
              input no
            , input p-last-xml-file-name
            , input p-list-file-name
            , input p-last-xml-file-number
            , input yes
            , input v-prev-filename + "xml":U
            , input ""
            , input ""
            , input p-parameter-list
        ).
        assign
            v-need-new-file = no
        .
    end.        /* if v-need-new-file = yes */
    output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    .
    run bgelib-tag-open in this-procedure ( input 2, input "grp", input "" ).
    run bgelib-tag-put in this-procedure ( input 3, input "grpID"   , input string(buf_gds-grp.node-code)   , input 0 ).
    run bgelib-tag-put in this-procedure ( input 3, input "upperID" , input buf_gds-grp.upper-code          , input 0 ).
    run bgelib-tag-put in this-procedure ( input 3, input "name"    , input buf_gds-grp.node-name           , input 0 ).
    run bgelib-tag-close in this-procedure ( input 2, input "grp" ).
    output stream stmxmlout close.
end.
end procedure.