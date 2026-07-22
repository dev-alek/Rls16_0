block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: c-pr-del.p $
$Archive: str/c-pr-del.p $

Копирование переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 04/10/02 3:57


*/

define input parameter p-doc-num like ub.c-price-doc.doc-num no-undo .
define input parameter p-chip-num like ub.c-price-doc.chip-num no-undo .

message " удаление в истории состава переоценки" skip
          p-doc-num  skip
          p-chip-num skip
         view-as alert-box information .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: c-pr-del.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/c-pr-del.p $":U .
def var vss-description as character no-undo init "Копирование переоценки ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
do :
find first ub.c-price-doc where ub.c-price-doc.doc-num  = p-doc-num
                            and ub.c-price-doc.chip-num = p-chip-num  exclusive-lock  no-error .
if error-status :error then return error.
      for each ub.c-price-list where ub.c-price-list.doc-num  = p-doc-num
                                and ub.c-price-list.chip-num = p-chip-num  exclusive-lock  :
        delete ub.c-price-list.
      end.
   delete ub.c-price-doc.
end.