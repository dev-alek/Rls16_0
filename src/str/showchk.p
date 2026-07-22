block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: showchk.p $
$Archive: str/showchk.p $

Просмотр чека и чека МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/02/04
Author: Bakhtadze Natalya
Creation date: 03/02/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
define input parameter p-is-wth as logical no-undo .
define input parameter p-br-handle as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: showchk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/showchk.p $":U .
define variable vss-description as character no-undo init "Просмотр чека и чека МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define variable v-doc-rec as recid no-undo .
define variable glog as logical no-undo .

define new shared buffer c-doc for ub.chk-doc.
DEFINE new SHARED BUFFER chk-doc FOR ub.chk-doc.
define variable next-prev as character no-undo .
define variable v-host-code        as integer   no-undo .
define variable v-object-available as logical   no-undo .



do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  CASE p-is-wth
  :
   when yes then do:
      find first chk-doc no-lock where
                chk-doc.doc-code = p-doc-code no-error .
      if available chk-doc
      then do:

        { gbl/hostcode.i
          chk-doc.obj-type
          chk-doc.obj-code
          v-host-code
        }

        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_wth-receipts_lookup':U
          {&cntxt-object}
          v-host-code
          chk-doc.obj-type
          chk-doc.obj-code
          0
          0
          0
          true
          glog
        }
        if glog <> true then return .

        { gbl/usobjava.i
          v-cntxt-db-num
          {&action-head-code-main}
          v-cntxt-userid
          chk-doc.obj-type
          chk-doc.obj-code
          v-object-available
        }
        if v-object-available <> true
        then do:
          return.
        end.
       assign
       v-doc-rec = recid(chk-doc)
       .
       run str/checkwth.w
                      ( input parparentproc
                       ,input {&lookup}
                       ,input chk-doc.obj-type
                       ,input chk-doc.obj-code
                       ,input-output v-doc-rec
                       ,input ? /*this-procedure:handle*/
                       ,input-output next-prev
                                    )  no-error
        .
     end.
   end.
   when no then do:
     find first c-doc no-lock where
               c-doc.doc-code = p-doc-code no-error .
     if available c-doc
     then do:
        { gbl/usobjava.i
          v-cntxt-db-num
          {&action-head-code-main}
          v-cntxt-userid
          c-doc.obj-type
          c-doc.obj-code
          v-object-available
        }
        if v-object-available <> true
        then do:
         return .
       end.
       assign
       v-doc-rec = recid(c-doc)
       .
       run str/superchk.w
                      (
                        parparentproc
                       ,input {&lookup}
                       ,input c-doc.obj-type
                       ,input c-doc.obj-code
                       ,input-output v-doc-rec
                       ,input p-br-handle /*this-procedure:handle*/
                       ,input-output next-prev
                                    ) no-error
        .
      end.
    end.
 END CASE.

end.