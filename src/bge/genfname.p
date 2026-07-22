block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: genfname.p $
$Archive: bge/genfname.p $

Процедура определения имени для нового файла.

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06


Input:
    p-full-path         - Полный путь
    p-prefix            - Префикс имени файла
    p-user-chars        - Набор символов для имени
    p-extension         - Расширение основного файла без "."
    p-temp-extension    - Расширение временного файла без "." ("" - запись в файл будет напрямую, без временного файла)
Output:
    p-name              - полное имя сгенерированного файла
*/
define input parameter p-full-path      as character    no-undo.
define input parameter p-prefix         as character    no-undo.
define input parameter p-user-chars     as character    no-undo.
define input parameter p-extension      as character    no-undo.
define input parameter p-temp-extension as character    no-undo.
define output parameter p-name          as character   no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: genfname.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/genfname.p $":U .
define variable vss-description as character no-undo init "Процедура определения имени для нового файла.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error return-value
:
    define variable v-base        as integer   no-undo .
    define variable v-check-name  as character no-undo .
    define variable v-locked      as logical   no-undo.
    define variable v-temp-name   as character      no-undo.

    assign
        file-info :file-name = p-full-path
    .
    if file-info :full-pathname = ?
    then do:
        undo, return error .
    end.
    if index(file-info :file-type, "D") = 0
    then do:
        undo, return error .
    end.
    assign
        p-full-path = file-info :full-pathname
    .
    if p-extension <> ""
    and substring(p-extension, 1, 1) <> '.':u
    then do:
        assign
            p-extension = '.':u + p-extension
        .
    end.
    if p-temp-extension <> ""
    and substring( p-temp-extension, 1, 1 ) <> '.':u
    then do:
        assign
            p-temp-extension = '.':u + p-temp-extension
        .
    end.
    /*
    * Loop until we find a name that hasn't been used. In theory, if the
    * temp directory gets filled, this could be an infinite loop. But, the
    * likelihood of that is low.
    */
    assign
        v-check-name = "something"
        v-locked     = yes
    .
    do
    while v-check-name <> ?
    :
        /* создается число из не более чем пять цифр */
        assign
            v-base = ( time * 1000 + etime ) modulo 100000
        .
        /* Add in the extension and directory into the name. */
        assign
            p-name      = p-full-path
                            + {&slash-char}
                            + p-prefix
                            + string( v-base,"99999":U )
                            + p-user-chars
                            + p-extension
            v-check-name = search( p-name )
        .
        if v-check-name = ?
        and p-temp-extension <> ""
        then do:
            assign
                v-temp-name  = p-full-path
                                + {&slash-char}
                                + p-prefix
                                + string( v-base,"99999":U )
                                + p-user-chars
                                + p-temp-extension
                v-check-name = search( v-temp-name )
            .
        end.
    end.        /* do while v-check-name <> ? */
end.