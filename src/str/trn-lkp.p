block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-lkp.p $
$Archive: str/trn-lkp.p $

Просмотр складского документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/
define input  parameter parparentproc as handle no-undo.
define input  parameter t-rid         as recid  no-undo .
define input  parameter parline-rec   as recid  no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trn-lkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/trn-lkp.p $":U .
define variable vss-description as character no-undo init "Просмотр складского документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }
define variable varnext-prev as logical no-undo.
define variable br-handle    as handle  no-undo.
define variable bf-handle    as handle  no-undo.
define variable varvalue-oldsuppcntr as character no-undo .
define variable vartype-oldsuppcntr  as character no-undo .
do
on error undo, return error return-value
:
define new shared buffer t-doc for ub.trn-doc.

  /* Query definitions                                                    */
  open query br-docs for each t-doc where recid (t-doc) = t-rid no-lock.
  get first br-docs .
  case t-doc.doc-type :
    when {&income} then do:
      if t-doc.internal = yes then do:
        run str/out-doc.w (input parparentproc, input-output t-rid, input {&lookup}, input ?, input {&income}, input yes, input-output varnext-prev, input t-doc.ext-doc-type, input ?, input-output parline-rec, input br-handle, input bf-handle, input t-doc.status_).
      end.
      else do:
        run str/in-doc.w  (input parparentproc, input-output t-rid, input {&lookup}, input {&inventory}, input no, input-output varnext-prev, input t-doc.ext-doc-type, input ?, input-output parline-rec, input br-handle , input bf-handle, input t-doc.status_).
      end.
    end.
    when {&write-off} or
    when {&return}    or
    when {&expense}   then do:
      run str/out-doc.w (input parparentproc, input-output t-rid, input {&lookup}, input ?, input t-doc.doc-type, input t-doc.internal, input-output varnext-prev, input t-doc.ext-doc-type, input ?, input-output parline-rec, input br-handle, input bf-handle , input t-doc.status_).
    end.
    when {&inventory} then do:
      if t-doc.ext-doc-type = {&TDEDT_Inv} then do:
        run str/inv-doc.w (input parparentproc, input-output t-rid, input {&lookup}, input {&inventory}, input no, input-output varnext-prev, input ?, input ?, input-output parline-rec, input br-handle , input bf-handle) .
      end.
      else do:
        if t-doc.ext-doc-type = {&TDEDT_Peresort} then do:
           { str/tdat-val.i
              t-doc.doc-code
              {&trdcattr-oldsuppcntr}
              varvalue-oldsuppcntr
              vartype-oldsuppcntr
              no-error}

           run str/peresort.w
                  (input        parparentproc,
                  input-output t-rid,
                  input        {&lookup},
                  input        {&TDEDT_Peresort},
                  input-output varnext-prev,
                  input-output parline-rec,
                  input        br-handle,
                  input        bf-handle,
                  input        t-doc.obj-type,
                  input        t-doc.obj-code,
                  input        t-doc.cli-type,
                  input        t-doc.cli-code,
                  input        (if varvalue-oldsuppcntr = "yes":u then yes else no),
                  input        t-doc.contract-code    ) .
        end.
        else do:
          run str/corparts.w (input parparentproc, input-output t-rid, input {&lookup}, input t-doc.ext-doc-type, input ?, input-output varnext-prev, input-output parline-rec, input br-handle , input bf-handle).
        end.
      end.
    end.
  end.
end.