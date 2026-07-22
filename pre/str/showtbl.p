block-level on error undo, throw.
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable v-user-table-name as character no-undo .
define variable v-r as recid no-undo .
do
on error undo, return error return-value
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run tblnmusr in g#library
  (input  p-doc-table
  ,output v-user-table-name
  )  .
  case p-doc-table :
    when 'trn-doc':U
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
    when 'price-doc':U
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
    when 'wth-doc':U
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
    when 'inkas':U
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
    when 'fbr-doc':U
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
    when 'rvs-doc':U
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
    when 'icnt-doc':U
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
    when 'ord-doc':U
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
    when 'ord-doc-rcv':U
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
