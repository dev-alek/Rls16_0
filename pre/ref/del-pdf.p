block-level on error undo, throw.
define input  parameter parParentproc as handle no-undo .
define input  parameter p-id     as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-pdf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/del-pdf.p $":U .
define variable vss-description as character no-undo init "Процедура удалить цены".
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
define variable v-ask as logical   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
    for each buf_price-doc-forming exclusive-lock where
             buf_price-doc-forming.plt-id     = p-id     and
             buf_price-doc-forming.plt-db-num = p-db-num
             :
             buf_price-doc-forming.stts = integer('1':U) .
             release buf_price-doc-forming.
     end.
       for each  ub.price-doc-forming no-lock  where
                 ub.price-doc-forming.plt-db-num   = p-db-num  and
                 ub.price-doc-forming.plt-id       = p-id :
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run a-nwspdf in g#library2
  (input  ub.price-doc-forming.plt-id
  ,input  ub.price-doc-forming.plt-db-num
  ,input  ub.price-doc-forming.pdf-id
  ,input  ub.price-doc-forming.pdf-db
  ,output v-ask
  )  .
          if v-ask then do:
            run str/diallog.w
                    ( input parparentproc
                    , input this-procedure
                    , input 'str/sendpdfr.p':U
                    , input ("D":U + chr(4) +
                            string(ub.price-doc-forming.plt-id) + chr(4)  +
                            string(ub.price-doc-forming.plt-db-num) + chr(4) +
                            string(ub.price-doc-forming.pdf-id) + chr(4)  +
                            string(ub.price-doc-forming.pdf-db)
                            )
                    , input yes
                    , input '':U
                    , input '') no-error .
                    if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "str/sendpdfr.p"
                      view-as alert-box error
                    .
                    end.
          end.
    end.
define buffer ch_price-list-type for ub.price-list-type .
for each ch_price-list-type no-lock  where
         ch_price-list-type.plt-main-id     = p-id     and
         ch_price-list-type.plt-main-db-num = p-db-num :
        for each buf_price-doc-forming exclusive-lock where
                 buf_price-doc-forming.plt-id     = ch_price-list-type.plt-id     and
                 buf_price-doc-forming.plt-db-num = ch_price-list-type.plt-db-num
                 :
                 buf_price-doc-forming.stts = integer('1':U) .
                 release buf_price-doc-forming.
        end.
       for each  ub.price-doc-forming no-lock  where
                 ub.price-doc-forming.plt-db-num   = ch_price-list-type.plt-db-num  and
                 ub.price-doc-forming.plt-id       = ch_price-list-type.plt-id :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run a-nwspdf in g#library2
  (input  ub.price-doc-forming.plt-id
  ,input  ub.price-doc-forming.plt-db-num
  ,input  ub.price-doc-forming.pdf-id
  ,input  ub.price-doc-forming.pdf-db
  ,output v-ask
  )  .
          if v-ask then do:
            run str/diallog.w
                    ( input parparentproc
                    , input this-procedure
                    , input 'str/sendpdfr.p':U
                    , input ("D":U + chr(4) +
                            string(ub.price-doc-forming.plt-id) + chr(4)  +
                            string(ub.price-doc-forming.plt-db-num) + chr(4) +
                            string(ub.price-doc-forming.pdf-id) + chr(4)  +
                            string(ub.price-doc-forming.pdf-db)
                            )
                    , input yes
                    , input '':U
                    , input '') no-error .
                    if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "str/sendpdfr.p"
                      view-as alert-box error
                    .
                    end.
          end.
          end.
end.
