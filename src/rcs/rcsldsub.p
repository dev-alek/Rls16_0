block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcsldsub.p $
$Archive: rcs/rcsldsub.p $

RCS: Начальная загрузка таблицы импорта товаров.

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define input-filename 'subj.csv'

define stream i-stream.

do
on error undo, return error
:


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcsldsub.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcsldsub.p $":U .
define variable vss-description as character no-undo init "RCS: Начальная загрузка таблицы импорта товаров.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define temp-table temp-codes no-undo
    field id-string         as character
    field obj-type-string   as character
    field obj-code-string   as character
index pi is primary unique id-string
.

define buffer buf_rcs-retail1subject        for rcs-retail1subject.

    create temp-codes.
    input stream i-stream from {&input-filename}.
    do transaction
    :
	    repeat
	    :
	        find first temp-codes.
	        import stream i-stream delimiter "," temp-codes no-error .
	        if error-status :error
	        then do:
	        	message
		        	"Ошибка импорта, ID=" temp-codes.id-string
		        	skip "Закачка отменена. "
		        	skip "Исправьте файл импорта и повторите операцию."
		        	skip return-value
		        	skip error-status :get-message (1)
		        	skip error-status :get-message (2)
	        	view-as alert-box error.
	        	undo, return error.
	        end.
	        create buf_rcs-retail1subject.
	        assign
	            buf_rcs-retail1subject.id                   = temp-codes.id-string
	            buf_rcs-retail1subject.obj-type             = temp-codes.obj-type-string
	            buf_rcs-retail1subject.obj-code             = integer( temp-codes.obj-code-string )
	            buf_rcs-retail1subject.file-name            = {&input-filename}
	            buf_rcs-retail1subject.imp-date             = today
	            buf_rcs-retail1subject.imp-time             = time
	            buf_rcs-retail1subject.imp-user             = g#userid
	        .
	    end.
    end.
end.