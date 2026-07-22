block-level on error undo, throw.
define input  parameter  parparentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prpar-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prpar-1.p $":U .
define variable vss-description as character no-undo init "Пересчет документов по продажным ценам по партиям".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable p-doc-code as character no-undo .
define variable v-r-b as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-r-b
  )  .
  run gbl/d-prompt.w
    ( 'title=Введите Номер документа\'
    + 'format=x(15)\'
    + 'type=char\'
    ,input-output p-doc-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
find first ub.trn-doc exclusive-lock where
           ub.trn-doc.doc-code = p-doc-code no-error .
  if ub.trn-doc.doc-type = 'при':U then do:
      message "Приходы не пересчитываем ! "  view-as alert-box error .
      return .
  end.
  for each ub.doc-line no-lock where
          ub.doc-line.doc-code = ub.trn-doc.doc-code :
      find first ub.gds-obj no-lock where
                ub.gds-obj.obj-type   = ub.trn-doc.obj-type   and
                ub.gds-obj.obj-code   = ub.trn-doc.obj-code   and
                ub.gds-obj.artic      = ub.doc-line.artic     and
                ub.gds-obj.prod-type  = ub.doc-line.prod-type and
                ub.gds-obj.prod-code  = ub.doc-line.prod-code and
                ub.gds-obj.cash-parts = true no-error .
       if not available ub.gds-obj then next.
       for each ub.gds-dtl exclusive-lock where
                ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
                ub.gds-dtl.artic     = ub.doc-line.artic     and
                ub.gds-dtl.prod-type = ub.doc-line.prod-type and
                ub.gds-dtl.prod-code = ub.doc-line.prod-code
                :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(ub.gds-dtl)
  , input no
  , input ub.gds-dtl.doc-qnty
  ) no-error.
      end.
  end.
  run gbl/calc-trn.p (parparentproc ,recid(ub.trn-doc)) no-error .
  message "Все" view-as alert-box information .
