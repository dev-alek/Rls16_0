block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calloxml.p $
$Archive: str/calloxml.p $

Маршрутизация OpenXML

Автор: Хныкин Павел Андреевич
Дата создания: 10/25/05
Author: Pavel Khnykin
Creation date: 10/25/05

Input:

Output:

*/

define input parameter p-action     as character        no-undo.
define input parameter p-tbl-name   like ub.esys-route.esr-name-rec no-undo .
define input parameter p-tbl-handle as handle           no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: calloxml.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/calloxml.p $":U .
define variable vss-description as character no-undo initial "Маршрутизация OpenXML":U .

{ cmp/vssrevis.i "substitute('&1|&2',p-tbl-name,p-tbl-handle)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }

    define variable v-cur-db-num        as integer      no-undo.
    define variable v-ext-sys-id-list   as character    no-undo.

    define buffer buf_datatype-table        for ub.datatype-table.
    define buffer buf_datatype-table-exp    for ub.datatype-table-exp.
    define buffer buf_ext-system            for ub.ext-system.
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_BatchProcess          for ub.BatchProcess.
do
for buf_datatype-table
  , buf_datatype-table-exp
  , buf_esys-datatype-exp
  , buf_ext-system
  , buf_BatchProcess
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
:
    find first buf_datatype-table no-lock
         where buf_datatype-table.dtt-name = p-tbl-name
    no-error.
    if available buf_datatype-table
    then do:
        assign
            v-ext-sys-id-list = "":U
        .
        { gbl/curdbnum.i
            v-cur-db-num
        }
        for each buf_datatype-table-exp no-lock
           where buf_datatype-table-exp.dtt-name = buf_datatype-table.dtt-name
        on error undo, return error
        :
/*            if buf_datatype-table-exp.dtte-status = 1*/
/*            then do:*/
                for each buf_esys-datatype-exp no-lock
                   where buf_esys-datatype-exp.db-num    = v-cur-db-num
                     and buf_esys-datatype-exp.dte-id    = buf_datatype-table-exp.dte-id
                on error undo, return error
                :
/*                    if buf_datatype-table-exp.dtte-status = 1*/
/*                    then do:*/
                        for each buf_ext-system no-lock
                           where buf_ext-system.esys-id = buf_esys-datatype-exp.esys-id
                             and buf_ext-system.db-num  = buf_esys-datatype-exp.db-num
                        on error undo, return error
                        :
                            if buf_ext-system.esys-type = integer({&openxml-type-ordinal})
                            and ( buf_ext-system.esys-status = -1
                               or buf_ext-system.esys-status = 1 )
                            then do:
/*                                message*/
/*                                    "Данные из таблицы" p-tbl-name*/
/*                                    skip "определены во вн.с." buf_ext-system.esys-name*/
/*                                view-as alert-box information.*/
                                { trg/btpr_upd.i
                                    &btpr-status="find"
                                    &btpr-type="{&btpr-type-oxml-new}"
                                    &btpr-table="buf_BatchProcess"
                                    &btpr-lock-option="exclusive-lock"
                                    &key#_one=buf_ext-system.esys-id
                                    &key#_two=buf_ext-system.db-num
                                }
                                if available buf_BatchProcess
                                then do:
                                    undo, return error
                                        substitute( "Идёт инициализация внешней системы '&3'&1&2 записи возможно только после завершения инициализации."
                                            , {&new-line}
                                            , ( if p-action = {&nwsdochs_action_delete} then "Удаление" else "Изменение" )
                                            , buf_ext-system.esys-name
                                        ).
                                end.
                                assign
                                    v-ext-sys-id-list = substitute( "&1&2&3":U
                                                            , v-ext-sys-id-list
                                                            , ( if v-ext-sys-id-list = "":U then "":U else {&delim-nws} )
                                                            , buf_ext-system.esys-id
                                                        )
                                .
                            end.
                        end.        /* for each buf_ext-system */
/*                    end.        /* if buf_datatype-table-exp.dtte-status = 1 */*/
                end.        /* for each buf_esys-datatype-exp */
/*            end.        /* if buf_datatype-table-exp.dtte-status = 1 */*/
        end.        /* for each buf_datatype-table-exp */
        if v-ext-sys-id-list <> "":U
        then do:
            run nws/cr-route.p (
                  input substitute( "&1,&2", {&send-tbl-oxml}, p-action )
                , input p-tbl-name
                , input p-tbl-handle
                , input v-ext-sys-id-list
            ) no-error.
            if error-status :error
            then do:
                return error return-value.
            end.
        end.        /* if v-ext-sys-id-list <> "":U */
    end.
end.  /*  do  on error  undo,  return  error:  */