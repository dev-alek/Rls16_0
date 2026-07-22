block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: showtbl.p $
$Archive: str/showtbl.p $

Показать документ

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/26/03

TODO - переходить на указанный товар


*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-doc-table as character no-undo .
define input  parameter p-doc-code  as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: showtbl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/showtbl.p $":U .
define variable vss-description as character no-undo initial "Показать складской документ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }

define variable v-user-table-name as character no-undo .
define variable v-r as recid no-undo .

do
on error undo, return error return-value
:
  { gbl/tblnmusr.i
    p-doc-table
    v-user-table-name
  }

  case p-doc-table :
    when {&table_trn-doc}
    then do:
      define buffer buf_trn-doc for ub.trn-doc .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      else do:
        run str/showdoc.p
          (input parparentproc
          ,input p-doc-code
          ,input ""
          ,input ""
          ,input 0
          ,input true
          ) .
      end.
    end.
    when {&table_price-doc}
    then do:
      define buffer buf_price-doc for ub.price-doc .
      find first buf_price-doc no-lock
        where buf_price-doc.doc-num = p-doc-code
        no-error .
      if not available buf_price-doc
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      else do:
        run str/showdoc.p
          (input parparentproc
          ,input p-doc-code
          ,input ""
          ,input ""
          ,input 0
          ,input false
          ) .
      end.
    end.
    when {&table_wth-doc}
    then do:
      define buffer buf_wth-doc for ub.wth-doc .
      find first buf_wth-doc no-lock
        where buf_wth-doc.doc-code = p-doc-code
        no-error .
      if not available buf_wth-doc
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      run str/wthd-lkp.p
        (input parparentproc
        ,input recid(buf_wth-doc)
        ) .
    end.
    when {&table_inkas}
    then do:
      define buffer buf_inkas for ub.inkas .
      find first buf_inkas no-lock
        where buf_inkas.inkas-code = p-doc-code
        no-error .
      if not available buf_inkas
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      run str/ink-lkp.p
        (input parparentproc
        ,input recid(buf_inkas)
        ).
    end.
    when {&table_fbr-doc}
    then do:
      define buffer buf_fbr-doc for ub.fbr-doc .
      find first buf_fbr-doc no-lock
        where buf_fbr-doc.doc-code = p-doc-code
        no-error .
      if not available buf_fbr-doc
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      run str/fbr-lkp.p (
          input parparentproc
        , input recid( buf_fbr-doc )
      ).
    end.
    when {&table_rvs-doc}
    then do:
      define buffer buf_rvs-doc for ub.rvs-doc .
      find first buf_rvs-doc no-lock
        where buf_rvs-doc.rvs-code = p-doc-code
        no-error .
      if not available buf_rvs-doc
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      run str/rvs-lkp.p
        (input parparentproc,
         input buf_rvs-doc.rvs-code
        ).
    end.
    when {&table_icnt-doc}
    then do:
      define buffer buf_icnt-doc for ub.icnt-doc .
      find first buf_icnt-doc no-lock
        where buf_icnt-doc.doc-code = p-doc-code
        no-error .
      if not available buf_icnt-doc
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      define variable v-recid as recid     no-undo .
      define variable v-docc-code as character no-undo .
      v-docc-code = buf_icnt-doc.doc-code .
      run str/icnt-lkp.p ( input parparentproc
                          ,input v-recid) no-error.
    end.
    when {&table_ord-doc}
    then do:
      define buffer buf_ord-doc for ub.ord-doc .
      find first buf_ord-doc no-lock
        where buf_ord-doc.doc-code = p-doc-code
        no-error .
      if not available buf_ord-doc
      then do:
        message
          "Документ не найден" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
       run cus/show-ord.p
        (input parparentproc
        ,input recid(buf_ord-doc)
        ) .
    end.
    when {&table_ord-doc-rcv}
    then do:
      define buffer buf_ord-doc-rcv for ub.ord-doc-rcv .
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = p-doc-code
        no-error .
      if not available buf_ord-doc-rcv
      then do:
        message
          "Документ не найден 1" skip
          v-user-table-name p-doc-code skip
          view-as alert-box information .
        undo, return .
      end.
      v-r = recid(buf_ord-doc-rcv).
      run cus/lkp-rcv.w
        (input parparentproc
        ,input-output v-r
        ) .
   end.

/* todo - реализовать вызов формы просмотра заказов */
/*    when {&table_ord-cons}*/
/*    then do:*/

/*    end.*/
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Просмотр данного типа документа пока не реализован" skip
        "Тип документа" p-doc-table skip
        "Код документа" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
end.