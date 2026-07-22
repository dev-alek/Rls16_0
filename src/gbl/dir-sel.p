block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dir-sel.p $
$Archive: gbl/dir-sel.p $

Выбор каталога.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
define output parameter p-dir-name  as character no-undo .
define output parameter p-dir-type  as character no-undo .
define output parameter p-can-write as logical   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dir-sel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dir-sel.p $":U .
define variable vss-description as character no-undo init "Выбор каталога.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/windows.i  }

do
on error undo, return error
:
    define variable v-memptr        as memptr       no-undo.
    define variable v-dir-name      as character    no-undo.
    define variable v-success-ind   as integer      no-undo.
    define variable v-success-ind2  as integer      no-undo.

    set-size( v-memptr )    = 1000.
    assign
        v-dir-name              = FILL (" ",255)
    .
    select-directory:
    do while true
    :
        run SHBrowseForFolder in hpApi  (
              input v-memptr
            , output v-success-ind
        ).
        if v-success-ind = 0
        then do:
            leave select-directory.
        end.
        run SHGetPathFromIDList in hpApi (
              input v-success-ind
            , INPUT-OUTPUT v-dir-name
            , OUTPUT v-success-ind2
        ).
        assign
            file-info :file-name = v-dir-name
        .
        assign
            p-dir-name = file-info :file-name
            p-dir-type = file-info :file-type
            p-can-write = ( index( p-dir-type, "W" ) > 0 )
        .
        if index( p-dir-type, "D" ) = 0
        then do:
            message
                "Выбранный каталог недоступен."
                skip "Каталог:" v-dir-name
                skip "Выберите другой каталог"
            view-as alert-box error .
        end.
        else do:
            leave select-directory.
        end.
    end.
    set-size( v-memptr ) = 0.
    /*MESSAGE */
    /*  v-dir-name skip*/
    /*  file-info :file-name skip*/
    /*  file-info :pathname skip*/
    /*  file-info :file-type skip*/
    /* VIEW-AS ALERT-BOX.*/
end.
