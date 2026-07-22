block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-copy.p $
$Archive: str/pr-copy.p $

Копирование переоценок по списку объектов.

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/26/02 3:40
*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter x-doc-num as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-copy.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-copy.p $":U .
define variable vss-description as character no-undo init "Копирование переоценок по списку объектов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ trg/check-bc.i }

define variable new-price-num  as character no-undo .
define variable new-rec as recid no-undo .
define variable g#log as logical no-undo .

define buffer b-price-doc for price-doc   .
define buffer b-price-list for price-list .
define buffer new-price-doc for price-doc   .
define buffer new-price-list for price-list .

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  define variable v-user-select as logical   no-undo .
  { gbl/uobjsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
    return .
  end.

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  for each buf_userobjs_temp-user-obj
  on error undo, return error return-value
  :

    find first clients no-lock
      where clients.obj-type = buf_userobjs_temp-user-obj.obj-type
        and clients.obj-code = buf_userobjs_temp-user-obj.obj-code
      no-error .
    find first b-price-doc no-lock
      where b-price-doc.doc-num = x-doc-num
      no-error .

    if not available b-price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "не найдена переоценка" x-doc-num
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* создадим шапочку */
    define variable p-price-doc-recid  as recid no-undo .
    define variable calc-rec     as recid        no-undo.

    run prcreate-new-price-doc in this-procedure ( input v-cntxt-db-num ,
                                  input clients.obj-type  ,
                                  input clients.obj-code   ,
                                  input b-price-doc.plt-id      ,
                                  input b-price-doc.plt-db-num  ,
                                  input b-price-doc.pdf-id      ,
                                  input b-price-doc.pdf-db  ,
                                  output p-price-doc-recid  ) .
    find first new-price-doc where recid(new-price-doc) =  p-price-doc-recid  exclusive-lock  no-error .
          new-price-doc.PS = b-price-doc.ps + " --- копия переоценки № " + x-doc-num .

    for each b-price-list  where b-price-list.doc-num = x-doc-num no-lock :
      /* coздадим строчки */
              run cre-pr-list in this-procedure (
                    input   b-price-list.b-code   ,
                    input   new-price-doc.doc-num ,
                    output  calc-rec   ) .
    find first new-price-list where recid(new-price-list) =  calc-rec  exclusive-lock  no-error .
          if available new-price-list then
            new-price-list.price-sale = b-price-list.price-sale  .
    end.
  end.
end.
  { str/alt-calc.i func }
  { str/alt-calc.i proc }
  { str/alt-calc.i "ver-modificator-price-is-null" }
  { str/doc-code.i }
  { str/alt-calc.i "exp-prt" }