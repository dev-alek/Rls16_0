block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oxmlinit.p $
$Archive: bge/oxmlinit.p $

OpenXML. Начальная выгрузка данных внешней системы

Автор: Хныкин Павел Андреевич
Дата создания: 05/08/07
Author: Pavel Khnykin
Creation date: 05/08/07

Input:

Output:

*/

define input parameter p-parent-handle      as handle           no-undo.
define input parameter p-esys-id            as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlinit.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlinit.p $":U .
define variable vss-description as character no-undo init "OpenXML. Начальная выгрузка данных внешней системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

    define variable v-table-handle      as handle       no-undo.
    define variable v-query-handle      as handle       no-undo.

    define buffer buf_ext-system            for ub.ext-system.
    define buffer buf_datatype-table        for ub.datatype-table.
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_datatype-table-exp    for ub.datatype-table-exp.
do
for buf_ext-system
  , buf_datatype-table
  , buf_esys-datatype-exp
  , buf_datatype-table-exp
on error undo, return error
:
    do transaction
    on error undo, return error
    :
        find first buf_ext-system exclusive-lock
             where buf_ext-system.esys-id   = p-esys-id
               and buf_ext-system.db-num    = p-db-num
        .
    end.        /* do transaction */
    find current buf_ext-system .
    for each buf_esys-datatype-exp no-lock
       where buf_esys-datatype-exp.esys-id  = p-esys-id
         and buf_esys-datatype-exp.db-num   = p-db-num
    on error undo, return error
    :
        for each buf_datatype-table-exp no-lock
           where buf_datatype-table-exp.dte-id  = buf_esys-datatype-exp.dte-id
        on error undo, return error
        :
            find first buf_datatype-table no-lock
                 where buf_datatype-table.dtt-name = buf_datatype-table-exp.dtt-name
            no-error.
            if available buf_datatype-table
            then do:
                create buffer v-table-handle for table buf_datatype-table-exp.dtt-name.
                create query v-query-handle.
                v-query-handle :set-buffers( v-table-handle ).
                v-query-handle :query-prepare( substitute( "for each &1", buf_datatype-table-exp.dtt-name ) ).
                v-query-handle :query-open.
                v-query-handle :get-first().
                repeat
                :
                    v-query-handle :get-next().
                    if v-query-handle :query-off-end then leave.
                    run nws/cr-route.p (
                          input substitute( "&1,&2", {&send-tbl-oxml}, {&nwsdochs_action_update} )
                        , input buf_datatype-table-exp.dtt-name
                        , input v-table-handle
                        , input string( p-esys-id )
                    ) no-error.
                    if error-status :error
                    then do:
                        return error return-value.
                    end.
                end.
                delete object v-query-handle.
                delete object v-table-handle.
            end.        /* if available buf_datatype-table */
        end.        /* for each datatype-table-exp */
    end.        /* for each buf_esys-datatype-exp */
    do transaction
    on error undo, return error
    :
        find first buf_ext-system exclusive-lock
             where buf_ext-system.esys-id   = p-esys-id
               and buf_ext-system.db-num    = p-db-num
        .
        assign
            buf_ext-system.esys-status = integer( {&openxml-status-working} ).
        .
    end.        /* do transaction */
end.