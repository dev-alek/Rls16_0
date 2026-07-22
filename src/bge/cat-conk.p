block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cat-conk.p $
$Archive: bge/cat-conk.p $

Экспорт справочника условий хранения.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-mode           as character    no-undo.
define output parameter p-locked        as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cat-conk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cat-conk.p $":U .
define variable vss-description as character no-undo init "Экспорт справочника условий хранения.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bge-xml.i  }

    define variable v-home-dir          as character    no-undo.
    define variable v-file-name         as character    no-undo.
    define variable v-log-file-name-ext as character    no-undo.

    define buffer buf_condition-keeping     for ub.condition-keeping.
do
for buf_condition-keeping
on error undo, return error
:
    run bge-xml-get-ref-filename in this-procedure (
          input "conk":U
        , output v-home-dir
        , output v-file-name
        , output p-locked
    ).
    if p-locked = yes
    then do:
        undo, return error.
    end.
    assign
        v-log-file-name-ext = substitute( "&1\&2", v-home-dir, "Actions.log":U )
    .
    run wp-XMLWriteLog in this-procedure ( input v-log-file-name-ext, input 0, input "&Line" ).
    run wp-XMLWriteLog in this-procedure ( input v-log-file-name-ext, input 1, input "XML - Вывод справочника условий хранения" ).

    run bge-xml-write-ref-header in this-procedure (
          input "conk":U
        , input v-file-name
    ).
    for each buf_condition-keeping no-lock
       where buf_condition-keeping.sts <> integer( {&deleted-status-int} )
    on error undo, return error
    :
        run write-condition-keeping-line in this-procedure (
            input buf_condition-keeping.cond-keep-code
        ).
    end.        /* for each buf_condition-keeping */
    run bge-xml-write-ref-footer in this-procedure (
        input v-file-name
    ).
end.

/*==========================================================================*/
procedure write-condition-keeping-line :
define input parameter p-cond-keep-code     as integer          no-undo.
    define buffer buf_condition-keeping     for ub.condition-keeping.
do
for buf_condition-keeping
on error undo, return error
:
    find first buf_condition-keeping no-lock
         where buf_condition-keeping.cond-keep-code = p-cond-keep-code
    .
    run wp-XMLTagOpen in this-procedure ( input 2, input "conk":U, input "" ).
    run wp-XMLTagPut in this-procedure ( input 3, input "condKeepCode"      , input string( p-cond-keep-code )                      , input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input "condKeepName"      , input string( buf_condition-keeping.cond-keep-name )  , input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input "condKeepDes"       , input string( buf_condition-keeping.des )             , input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input "condKeepHModeFrom" , input string( buf_condition-keeping.h-mode-from )     , input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input "condKeepHModeTo"   , input string( buf_condition-keeping.h-mode-to )       , input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input "condKeepTModeFrom" , input string( buf_condition-keeping.t-mode-from )     , input 0 ).
    run wp-XMLTagPut in this-procedure ( input 3, input "condKeepTModeTo"   , input string( buf_condition-keeping.t-mode-to )       , input 0 ).
    run wp-XMLTagClose in this-procedure ( input 2, input "conk":U ).
end.
end procedure. /* write-condition-keeping-line */