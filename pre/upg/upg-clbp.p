block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: upg-clbp.p $":U .
def var vss-archive     as character no-undo init "$Archive: upg/upg-clbp.p $":U .
def var vss-description as character no-undo init "удаление всех записей BatchProcess с типом ".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
do
on error undo, return error
:
  define buffer buf_BatchProcess for BatchProcess.
  for each buf_BatchProcess
    where buf_BatchProcess.BP_Type = 'autoupg':U
  on error undo, return error
  :
    delete buf_BatchProcess .
  end.
end.
