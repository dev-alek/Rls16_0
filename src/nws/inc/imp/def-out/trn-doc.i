/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06


*/
define temp-table locb-doc-line             no-undo like ub.doc-line.
define temp-table locb-doc-line-attr        no-undo like ub.doc-line-attr.
define temp-table locb-inv-line             no-undo like ub.inv-line.
define temp-table locb-doc-line-sum         no-undo like ub.doc-line-sum.
define temp-table locb-inv-doc              no-undo like ub.inv-doc.
define temp-table locb-trn-doc-sum          no-undo like ub.trn-doc-sum.
define temp-table locb-gds-dtl              no-undo like ub.gds-dtl.
define temp-table locb-parts                no-undo like ub.parts.
define temp-table locb-marking-lines        no-undo like ub.marking-lines.
define temp-table locb-doc-prts             no-undo like ub.doc-prts.
define temp-table locb-doc-pl               no-undo like ub.doc-pl.
define temp-table locb-doc-pl-attr          no-undo like ub.doc-pl-attr.
define temp-table locb-doc-pl-pump          no-undo like ub.doc-pl-pump.
define temp-table locb-parts-root           no-undo like ub.parts-root.
define temp-table locb-parts-attr           no-undo like ub.parts-attr.
define temp-table locb-parts-supp           no-undo like ub.parts-supp.
define temp-table locb-gen-attr             no-undo like ub.gen-attr.
define temp-table locbt-doc-attr            no-undo like ub.doc-attr.
define temp-table locb-doc-fbr-gds          no-undo like ub.doc-fbr-gds.
define temp-table locb-arh-trn-doc-contract no-undo like ub.arh-trn-doc-contract.
define temp-table tdlocb-chk-doc            no-undo like ub.chk-doc.
define temp-table tdlocb-c-chk-doc          no-undo like ub.c-chk-doc.
define temp-table tdlocb-chk-gds            no-undo like ub.chk-gds.
define temp-table tdlocb-chk-gds-attr       no-undo like ub.chk-gds-attr.
define temp-table tdlocb-c-chk-gds          no-undo like ub.c-chk-gds.
define temp-table tdlocb-chk-doc-attr       no-undo like ub.chk-doc-attr.
define temp-table tdlocb-c-chk-doc-attr     no-undo like ub.c-chk-doc-attr.
define temp-table locb-ord-chain            no-undo like ub.ord-chain.
define temp-table tdlocb-marking-chk        no-undo like ub.marking-chk.
define buffer locb-rc-arh-trn-doc-contract for locb-arh-trn-doc-contract.
{ str/libtfarh.i }
{ str/trdcalib.i }

PROCEDURE proc-load-trn-doc-inv-chk:
  define input parameter p-doc-code as character no-undo.
define buffer buf_chk-doc                  for ub.chk-doc.
define buffer buf_c-chk-doc                for ub.c-chk-doc.
define buffer buf_chk-gds                  for ub.chk-gds.
define buffer buf_chk-gds-attr             for ub.chk-gds-attr.
define buffer buf_c-chk-gds                for ub.c-chk-gds.
define buffer buf_chk-doc-attr             for ub.chk-doc-attr.
define buffer buf_c-chk-doc-attr           for ub.c-chk-doc-attr.
define buffer buf_marking-chk              for ub.marking-chk.


  do
  on error  undo, return error substitute( "$proc-load-trn-doc-inv-chk-doc. &1&2&3", return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "$proc-load-trn-doc-inv-chk-doc. stop" )
  on endkey undo, return error substitute( "$proc-load-trn-doc-inv-chk-doc. endkey" )
  :

    /* ------------------------------- chk-doc-attr --------------------------------------------- */
    for each buf_chk-doc-attr where buf_chk-doc-attr.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_chk-doc-attr.
    end.
    for each tdlocb-chk-doc-attr where tdlocb-chk-doc-attr.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_chk-doc-attr.
      buffer-copy tdlocb-chk-doc-attr to buf_chk-doc-attr.
    end.

    /* ------------------------------- chk-doc ---------------------------------------------- */
    for each buf_chk-doc where buf_chk-doc.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_chk-doc.
    end.
    for each tdlocb-chk-doc where tdlocb-chk-doc.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_chk-doc.
      buffer-copy tdlocb-chk-doc to buf_chk-doc.
    end.
    /* ------------------------------- chk-gds --------------------------------------------- */
    for each buf_chk-gds where buf_chk-gds.out-code = p-doc-code
    on error  undo, return error
    :
      for each buf_chk-gds-attr where buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code and buf_chk-gds-attr.line-num = buf_chk-gds.line-num
      on error  undo, return error
      :
        delete buf_chk-gds-attr.
      end.
      for each buf_marking-chk where buf_marking-chk.doc-code = buf_chk-gds.doc-code and buf_marking-chk.line-num = buf_chk-gds.line-num
      on error  undo, return error
      :
        delete buf_marking-chk.
      end.
      delete buf_chk-gds.
    end.
    for each tdlocb-chk-gds where tdlocb-chk-gds.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_chk-gds.
      buffer-copy tdlocb-chk-gds to buf_chk-gds.
      
      for each tdlocb-chk-gds-attr where tdlocb-chk-gds-attr.doc-code = tdlocb-chk-gds.doc-code and tdlocb-chk-gds-attr.line-num = tdlocb-chk-gds.line-num
                            no-lock
      on error  undo, return error
      :
        create buf_chk-gds-attr.
        buffer-copy tdlocb-chk-gds-attr to buf_chk-gds-attr.
      end.
      
      for each tdlocb-marking-chk where tdlocb-marking-chk.doc-code = tdlocb-chk-gds.doc-code and tdlocb-marking-chk.line-num = tdlocb-chk-gds.line-num
                            no-lock
      on error  undo, return error
      :
        create buf_marking-chk.
        buffer-copy tdlocb-marking-chk to buf_marking-chk.
      end.
      
    end.
    /* ------------------------------- chk-pay ---------------------------------------------- */
    /*-----------пропускаем потому что в инвентаризации их быть не может----------------------*/
    /* ------------------------------- chk-discnt --------------------------------------------- */
    /*-----------пропускаем потому что в инвентаризации их быть не может------------------------*/
    /* ------------------------------- c-chk-doc-attr --------------------------------------------- */
    for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_c-chk-doc-attr.
    end.
    for each tdlocb-c-chk-doc-attr where tdlocb-c-chk-doc-attr.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_c-chk-doc-attr.
      buffer-copy tdlocb-c-chk-doc-attr to buf_c-chk-doc-attr.
    end.

    /* ------------------------------- c-chk-doc ---------------------------------------------- */

    /*для некоторых касс например ipc-servies-plus может быть ситуация когда чек удаляется и рождается снова с таким же кодом   в БД*/
    for each tdlocb-c-chk-doc where tdlocb-c-chk-doc.out-code = p-doc-code
                          no-lock,
        first buf_c-chk-doc where buf_c-chk-doc.doc-code = tdlocb-c-chk-doc.doc-code
                    and buf_c-chk-doc.out-code = ?
    on error  undo, return error
    :
      for each buf_c-chk-gds where buf_c-chk-gds.doc-code = tdlocb-c-chk-doc.doc-code:
        delete buf_c-chk-gds.
      end.
      for each buf_c-chk-doc-attr where buf_c-chk-doc-attr.doc-code = tdlocb-c-chk-doc.doc-code:
        delete buf_c-chk-doc-attr.
      end.
      delete buf_c-chk-doc.
    end.


    for each buf_c-chk-doc where buf_c-chk-doc.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_c-chk-doc.
    end.
    for each tdlocb-c-chk-doc where tdlocb-c-chk-doc.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_c-chk-doc.
      buffer-copy tdlocb-c-chk-doc to buf_c-chk-doc.
    end.
    /* ------------------------------- c-chk-gds --------------------------------------------- */
    for each buf_c-chk-gds where buf_c-chk-gds.out-code = p-doc-code
    on error  undo, return error
    :
      delete buf_c-chk-gds.
    end.
    for each tdlocb-c-chk-gds where tdlocb-c-chk-gds.out-code = p-doc-code
                          no-lock
    on error  undo, return error
    :
      create buf_c-chk-gds.
      buffer-copy tdlocb-c-chk-gds to buf_c-chk-gds.
    end.
    /* ------------------------------- c-chk-pay ---------------------------------------------- */
    /*-----------пропускаем потому что в инвентаризации их быть не может------------------------*/
    /* ------------------------------- c-chk-discnt ------------------------------------------- */
    /*-----------пропускаем потому что в инвентаризации их быть не может------------------------*/
    /*почистим за собой*/
    for each tdlocb-chk-doc
    on error  undo, return error
    :
      delete tdlocb-chk-doc.
    end.
    for each tdlocb-chk-doc-attr
    on error  undo, return error
    :
      delete tdlocb-chk-doc-attr.
    end.
    for each tdlocb-chk-gds
    on error  undo, return error
    :
      delete tdlocb-chk-gds.
    end.
    for each tdlocb-chk-gds-attr
    on error  undo, return error
    :
      delete tdlocb-chk-gds-attr.
    end.
    for each tdlocb-marking-chk
    on error  undo, return error
    :
      delete tdlocb-marking-chk.
    end.
    for each tdlocb-c-chk-doc
    on error  undo, return error
    :
      delete tdlocb-c-chk-doc.
    end.
    for each tdlocb-c-chk-doc-attr
    on error  undo, return error
    :
      delete tdlocb-c-chk-doc-attr.
    end.
    for each tdlocb-c-chk-gds
    on error  undo, return error
    :
      delete tdlocb-c-chk-gds.
    end.
  end.
END PROCEDURE. /* proc-load-trn-doc-inv-chk */