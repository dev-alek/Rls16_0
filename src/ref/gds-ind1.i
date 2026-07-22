/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение изменений в gds-obj-prop

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/23/05
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "gds-obj-prop-attr" &then
{ ref/gdspoatr.i }
&endif


procedure gds-ind1 :
main-block:
  do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
define input-output parameter p-doc-rec  as recid no-undo.
define input  parameter p-gds-code                   like  ub.gds-obj-prop.gds-code no-undo.
define input  parameter p-obj-type                   like  ub.gds-obj-prop.obj-type no-undo.
define input  parameter p-obj-code                   like  ub.gds-obj-prop.obj-code no-undo.
define input  parameter p-gdop-igt                   like  ub.gds-obj-prop.gdop-igt no-undo.
define input  parameter p-gdop-assort-min            like  ub.gds-obj-prop.gdop-assort-min  no-undo.
define input  parameter p-gdop-min-stock             like  ub.gds-obj-prop.gdop-min-stock   no-undo.
define input  parameter p-grop-level-always-presence like  ub.gds-obj-prop.grop-level-always-presence  no-undo.
define input  parameter p-grop-max-stock             like  ub.gds-obj-prop.grop-max-stock              no-undo.
define input  parameter p-grop-min-order             like  ub.gds-obj-prop.grop-min-order              no-undo.
&if "{1}" = "gds-obj-prop-attr" &then
DEFINE INPUT  PARAMETER TABLE  FOR tt0-gds-obj-prop-attr.
define buffer buf_tt0-gds-obj-prop-attr for tt0-gds-obj-prop-attr.
&endif

define buffer bufs_gds-obj-prop for ub.gds-obj-prop.

define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .

{ gbl/curdbnum.i v-db-num }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .



run cur-time in this-procedure(output v-date, output v-time).
  find first bufs_gds-obj-prop exclusive-lock where
            bufs_gds-obj-prop.gds-code          = p-gds-code   and
            bufs_gds-obj-prop.obj-type          = p-obj-type   and
            bufs_gds-obj-prop.obj-code          = p-obj-code  no-error .
    if not available bufs_gds-obj-prop then do:
        create bufs_gds-obj-prop.
        assign
            bufs_gds-obj-prop.gds-code           = p-gds-code
            bufs_gds-obj-prop.grop-date-update   = v-date
            bufs_gds-obj-prop.grop-time-update   = v-time
            bufs_gds-obj-prop.grop-db-num-update = v-db-num
            bufs_gds-obj-prop.obj-type           = p-obj-type
            bufs_gds-obj-prop.obj-code           = p-obj-code
        no-error .
        if error-status :error then message "Ошибка при создании записи" error-status :error error-status :get-message(1) .
    end.

if  p-gdop-igt                     <> ? then    bufs_gds-obj-prop.gdop-igt                   = p-gdop-igt.
if  p-gdop-assort-min              <> ? then    bufs_gds-obj-prop.gdop-assort-min            = p-gdop-assort-min.
if  p-gdop-min-stock               <> ? then    bufs_gds-obj-prop.gdop-min-stock             = p-gdop-min-stock  .
if  p-grop-level-always-presence   <> ? then    bufs_gds-obj-prop.grop-level-always-presence = p-grop-level-always-presence.
if  p-grop-max-stock               <> ? then    bufs_gds-obj-prop.grop-max-stock             = p-grop-max-stock           .
if  p-grop-min-order               <> ? then    bufs_gds-obj-prop.grop-min-order             = p-grop-min-order           .

      p-doc-rec = recid(bufs_gds-obj-prop)    .
&if "{1}" = "gds-obj-prop-attr" &then
for each buf_tt0-gds-obj-prop-attr
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if buf_tt0-gds-obj-prop-attr.attr-value <> ?
  and lookup(buf_tt0-gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) = 0
  then do:
    run gdspoatr-write in this-procedure (
                                            input p-gds-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                            ,input buf_tt0-gds-obj-prop-attr.attr-code
                                            ,input buf_tt0-gds-obj-prop-attr.attr-value
                                            ).
  end.
end.
&endif
 /*  release bufs_gds-obj-prop no-error.
  if error-status:error then do:
     message  substitute("Ошибка при сохранении записи  с кодом &1: &2: &3"
                             , p-gds-code
                             , error-status :get-message(1)
                             , return-value
                             )
                             view-as alert-box error .
    undo, return error "":U.

  end. */

end. /*doe*/
end procedure. /* gds-ind1 */