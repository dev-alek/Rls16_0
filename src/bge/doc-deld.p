block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doc-deld.p $
$Archive: bge/doc-deld.p $

Экспорт удаленных документов.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-host-code       as integer     no-undo.
define input parameter p-obj-type        as character   no-undo.
define input parameter p-obj-code        as integer     no-undo.
define input parameter p-date-from       as date        no-undo.
define input parameter p-date-to         as date        no-undo.
define input parameter sOutFile          as character   no-undo.
define input parameter sLogFile          as character   no-undo.
define input parameter hEDT              as handle      no-undo.
define input parameter hCNT              as handle      no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-deld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/doc-deld.p $":U .
define variable vss-description as character no-undo init "Экспорт удаленных документов.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ bge/bge-xml.i  }


    define buffer buf_c-trn-doc       for ub.c-trn-doc.

do
for buf_c-trn-doc
on error undo, return error
:

    output stream stmxmlout to value( soutfile + "xm1" ) convert target "1251" append.

    run wp-XMLWriteCNT( hCNT, "" ).
    run wp-XMLWriteEDT( hEDT, 4, "Операция: Выгрузка удаленных документов." ).
    run wp-XMLWriteLog( sLogFile, 0, "&Line" ).
    run wp-XMLWriteLog( sLogFile, 1, "XML - Вывод операции: Выгрузка удаленных документов." ).

    for each buf_c-trn-doc no-lock
       where buf_c-trn-doc.obj-type   = p-obj-type
         and buf_c-trn-doc.obj-code   = p-obj-code
         and buf_c-trn-doc.is-del     = yes
    :
        if  buf_c-trn-doc.corr-date >= p-date-from
        and buf_c-trn-doc.corr-date <= p-date-to
        then do:
            run wp-XMLWriteCNT( hCNT, string( buf_c-trn-doc.corr-date, "99/99/9999" ) + "  " + buf_c-trn-doc.doc-code ).
            run export-c-trn-doc in this-procedure (
                  input buf_c-trn-doc.doc-code
                , input buf_c-trn-doc.corr-user-db-num
                , input buf_c-trn-doc.chip-num
            ) no-error.
            if error-status :error
            then do:
                undo, return error vss-description + "Ошибка вывода документа " + buf_c-trn-doc.doc-code.
            end.
        end.
    end.

    output stream stmxmlout close.

end.

/*==========================================================================*/
procedure export-c-trn-doc :
define input parameter p-doc-code           as character    no-undo.
define input parameter p-corr-user-db-num   as integer          no-undo.
define input parameter p-chip-num           as integer          no-undo.

    define buffer buf_c-trn-doc   for ub.c-trn-doc.

    define variable v-firm-code as character no-undo .
do
for buf_c-trn-doc
on error undo, return error
:
    find first buf_c-trn-doc no-lock
         where buf_c-trn-doc.doc-code           = p-doc-code
           and buf_c-trn-doc.corr-user-db-num   = p-corr-user-db-num
           and buf_c-trn-doc.chip-num           = p-chip-num
    .

    assign
      v-firm-code = buf_c-trn-doc.cli-type + string( buf_c-trn-doc.cli-code )
    .

    run wp-xmltagopen( input 2, input "operation", input "" ).
    run wp-xmltagput( input 3, input "referenceNo"  , input buf_c-trn-doc.doc-code                                   , input 0 ).
    run wp-xmltagput( input 3, input "isDel"        , input "yes"                                                    , input 0 ).
    run wp-xmltagput( input 3, input "flagDel"      , input buf_c-trn-doc.is-del                                     , input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input string( buf_c-trn-doc.ext-doc-type                      ), input 0 ).
    run wp-xmltagput( input 3, input "host"         , input string( buf_c-trn-doc.host-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "store"        , input buf_c-trn-doc.obj-type + string( buf_c-trn-doc.obj-code ), input 0 ).
    run wp-xmltagput( input 3, input "dateDel"      , input string( buf_c-trn-doc.corr-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateDelXml"   , input bge-xml-date( buf_c-trn-doc.corr-date )                  , input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string( buf_c-trn-doc.doc-date  ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateDocXml"   , input bge-xml-date( buf_c-trn-doc.doc-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "dateFact"     , input string( buf_c-trn-doc.fact-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateFactXml"  , input bge-xml-date( buf_c-trn-doc.fact-date )                  , input 0 ).

    if buf_c-trn-doc.ext-doc-type <> {&TDEDT_Overturn}
    then do:
      run wp-xmltagput( input 3, input "firm"         , input v-firm-code                                              , input 0 ).
    end.

    run wp-xmltagput( input 3, input "factOrder"    , input string( buf_c-trn-doc.fact-order                        ), input 0 ).
    run wp-xmltagput( input 3, input "sysDate"      , input string( buf_c-trn-doc.sys-date ,"99.99.9999"            ), input 0 ).
    run wp-xmltagput( input 3, input "sysDateXml"   , input bge-xml-date( buf_c-trn-doc.sys-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "sysTime"      , input string( buf_c-trn-doc.sys-time                          ), input 0 ).
    run wp-xmltagput( input 3, input "outCode"      , input buf_c-trn-doc.out-code                                   , input 0).
    run wp-xmltagput( input 3, input "reasonCode"   , input string( buf_c-trn-doc.reason-code                       ), input 2 ).
    run wp-xmltagput( input 3, input "comment"      , input buf_c-trn-doc.PS                                         , input 0).
    run wp-xmltagclose( input 2, input "operation" ).
end.
end procedure. /* export-trn-doc */