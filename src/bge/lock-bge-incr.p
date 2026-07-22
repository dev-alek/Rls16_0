block-level on error undo, throw.
/*

$Revision: c89b59c2f62e, 135, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:48:25 2015 +0400 $
$Workfile: lock-bge-incr.p $
$Archive: bge/lock-bge-incr.p $

Блокировка объекта для экспорта во Внешнюю Бухгалтерию

Автор: Кирюхин Сергей
Дата создания: 01/07/14
SKiryxin
Creation date: 01/07/14

*/

define input parameter p-obj-type as character no-undo.
define input parameter p-obj-code as integer no-undo.
define parameter buffer buf_clients-attr for ub.clients-attr.

define variable vss-revision    as character no-undo init "$Revision: c89b59c2f62e, 135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:25 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lock-bge-incr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/lock-bge-incr.p $":U .
define variable vss-description as character no-undo init "Блокировка объекта для экспорта во Внешнюю Бухгалтерию".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute("&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message(1))
on stop   undo, return error substitute("&1. stop", vss-workfile)
on endkey undo, return error substitute("&1. endkey", vss-workfile):

    find first buf_clients-attr exclusive-lock
        where buf_clients-attr.obj-type = p-obj-type
          and buf_clients-attr.obj-code = p-obj-code
          and buf_clients-attr.attr-code = {&attr-bge-incr-cur} no-wait no-error.
          
    if not available buf_clients-attr then 
    do:
        if locked buf_clients-attr then
        do:
            return error "Объект уже выгружается.".
        end.
        else do:
            create buf_clients-attr.
            assign
            buf_clients-attr.obj-type = p-obj-type
            buf_clients-attr.obj-code = p-obj-code
            buf_clients-attr.attr-code = {&attr-bge-incr-cur}.
        end.
    end.
    
    find current buf_clients-attr share-lock.
    return.

end.