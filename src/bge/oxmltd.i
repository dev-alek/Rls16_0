/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

OpenXML. Списки и процедуры для выбора типов данных.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table temp_oxmltd_sel no-undo
    field id    as integer
    field sel   as logical

    index pi is primary unique
        id
.
define temp-table temp_oxmltd_not_sel no-undo
    field id    as integer
    field sel   as logical

    index pi is primary unique
        id
.


/*==========================================================================
    Заполнение таблиц типов данных внешней подсистемы
    Input:
        p-type - "imp":U или "exp":U

*/
procedure oxmltd-fill :
define input parameter p-type       as character        no-undo.
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.

    define buffer buf_datatype-exp              for ub.datatype-exp.
    define buffer buf_datatype-imp              for ub.datatype-imp.
    define buffer buf_esys-datatype-exp         for ub.esys-datatype-exp.
    define buffer buf_esys-datatype-imp         for ub.esys-datatype-imp.
    define buffer buf_temp_oxmltd_sel           for temp_oxmltd_sel.
    define buffer buf_temp_oxmltd_not_sel       for temp_oxmltd_not_sel.
do
for buf_datatype-exp
  , buf_datatype-imp
  , buf_esys-datatype-exp
  , buf_esys-datatype-imp
  , buf_temp_oxmltd_sel
  , buf_temp_oxmltd_not_sel
on error undo, return error
:
    case p-type
    :
        when {&openxml-import}
        then do:
            for each buf_datatype-imp no-lock
            on error undo, return error
            :
                find first buf_esys-datatype-imp no-lock
                     where buf_esys-datatype-imp.esys-id = p-esys-id
                       and buf_esys-datatype-imp.db-num  = p-db-num
                       and buf_esys-datatype-imp.tdi-id  = buf_datatype-imp.dti-id
                no-error.
                if available buf_esys-datatype-imp
                then do:
                    create buf_temp_oxmltd_sel.
                    assign
                        buf_temp_oxmltd_sel.id = buf_datatype-imp.dti-id
                    .
                end.
                else do:
                    create buf_temp_oxmltd_not_sel.
                    assign
                        buf_temp_oxmltd_not_sel.id = buf_datatype-imp.dti-id
                    .
                end.
            end.        /* for each buf_datatype-imp */
        end.        /* when "imp":U */
        when {&openxml-export}
        then do:
            for each buf_datatype-exp no-lock
            on error undo, return error
            :
                find first buf_esys-datatype-exp no-lock
                     where buf_esys-datatype-exp.esys-id = p-esys-id
                       and buf_esys-datatype-exp.db-num  = p-db-num
                       and buf_esys-datatype-exp.dte-id  = buf_datatype-exp.dte-id
                no-error.
                if available buf_esys-datatype-exp
                then do:
                    create buf_temp_oxmltd_sel.
                    assign
                        buf_temp_oxmltd_sel.id = buf_datatype-exp.dte-id
                    .
                end.
                else do:
                    create buf_temp_oxmltd_not_sel.
                    assign
                        buf_temp_oxmltd_not_sel.id = buf_datatype-exp.dte-id
                    .
                end.
            end.        /* for each buf_datatype-exp */
        end.        /* when "exp":U */
    end case.       /* case type */
end.
end procedure. /* oxmltd-fill */

/*==========================================================================*/
procedure oxmltd-select-one :
define input parameter p-selected-id as integer          no-undo.

    define buffer buf_temp_oxmltd_sel       for temp_oxmltd_sel.
    define buffer buf_temp_oxmltd_not_sel   for temp_oxmltd_not_sel.
do
for buf_temp_oxmltd_sel
  , buf_temp_oxmltd_not_sel
on error undo, return error
:
    find first buf_temp_oxmltd_not_sel
         where buf_temp_oxmltd_not_sel.id = p-selected-id
    no-error.
    if available buf_temp_oxmltd_not_sel
    then do:
        delete buf_temp_oxmltd_not_sel.
        find first buf_temp_oxmltd_sel
            where buf_temp_oxmltd_sel.id = p-selected-id
        no-error.
        if not available buf_temp_oxmltd_sel
        then do:
            create buf_temp_oxmltd_sel.
            assign
                buf_temp_oxmltd_sel.id  = p-selected-id
                buf_temp_oxmltd_sel.sel = yes
            .
        end.
    end.
end.
end procedure. /* oxmltd-select-one */

/*==========================================================================*/
procedure oxmltd-deselect-one :
define input parameter p-selected-id as integer          no-undo.

    define buffer buf_temp_oxmltd_sel       for temp_oxmltd_sel.
    define buffer buf_temp_oxmltd_not_sel   for temp_oxmltd_not_sel.
do
for buf_temp_oxmltd_sel
  , buf_temp_oxmltd_not_sel
on error undo, return error
:
    find first buf_temp_oxmltd_sel
         where buf_temp_oxmltd_sel.id = p-selected-id
    no-error.
    if available buf_temp_oxmltd_sel
    then do:
        delete buf_temp_oxmltd_sel.
        find first buf_temp_oxmltd_not_sel
             where buf_temp_oxmltd_not_sel.id = p-selected-id
        no-error.
        if not available buf_temp_oxmltd_not_sel
        then do:
            create buf_temp_oxmltd_not_sel.
            assign
                buf_temp_oxmltd_not_sel.id  = p-selected-id
                buf_temp_oxmltd_not_sel.sel = yes
            .
        end.
    end.
end.
end procedure. /* oxmltd-select-one */

/*==========================================================================*/
procedure oxmltd-select :
define input parameter p-selected-id as integer          no-undo.

    define variable v-have-selected    as logical      no-undo.

    define buffer buf_temp_oxmltd_not_sel   for temp_oxmltd_not_sel.
do
for buf_temp_oxmltd_not_sel
on error undo, return error
:
    assign
        v-have-selected = no
    .
    for each buf_temp_oxmltd_not_sel
       where buf_temp_oxmltd_not_sel.sel = yes
    :
        run oxmltd-select-one in this-procedure (
            input buf_temp_oxmltd_not_sel.id
        ).
        assign
            v-have-selected = yes
        .
    end.
    if v-have-selected = no
    and p-selected-id <> 0
    then do:
        run oxmltd-select-one in this-procedure (
            input p-selected-id
        ).
    end.
end.
end procedure. /* oxmltd-select */

/*==========================================================================*/
procedure oxmltd-deselect :
define input parameter p-selected-id as integer          no-undo.

    define variable v-have-selected    as logical      no-undo.

    define buffer buf_temp_oxmltd_sel       for temp_oxmltd_sel.
do
for buf_temp_oxmltd_sel
on error undo, return error
:
    assign
        v-have-selected = no
    .
    for each buf_temp_oxmltd_sel
       where buf_temp_oxmltd_sel.sel = yes
    :
        run oxmltd-deselect-one in this-procedure (
            input buf_temp_oxmltd_sel.id
        ).
        assign
            v-have-selected             = yes
        .
    end.
    if v-have-selected = no
    and p-selected-id <> 0
    then do:
        run oxmltd-deselect-one in this-procedure (
            input p-selected-id
        ).
    end.
end.
end procedure. /* oxmltd-deselect */


/* $Workfile$ e n d */