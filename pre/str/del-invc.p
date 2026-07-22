block-level on error undo, throw.
define input parameter p-doc-code as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-invc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/del-invc.p $":U .
define variable vss-description as character no-undo init "Удаление чеков по инвентаризации".
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
define variable ii as integer no-undo .
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
.
FOR EACH ub.chk-doc WHERE
          ub.chk-doc.obj-type = p-obj-type AND
          ub.chk-doc.obj-code = p-obj-code AND
          ub.chk-doc.out-code = p-doc-code
on error undo _main, return error substitute("Ошибка при удалении/отвязывании чеков при удалении документа &1", p-doc-code)
          :
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-gds.
      end.
      else do:
        ub.chk-gds.out-code = ? .
        for each ub.marking-chk where ub.marking-chk.doc-code = ub.chk-gds.doc-code
                                  and ub.marking-chk.line-num = ub.chk-gds.line-num :
          ub.marking-chk.sts = 0 .
        end .
      end.
    END .
    FOR EACH ub.chk-pay WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-pay.
      end.
      else do:
        ub.chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-discnt WHERE
              ub.chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-discnt.
      end.
      else do:
        ub.chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-doc-attr WHERE
              ub.chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-doc-attr.
      end.
      else do:
         ub.chk-doc-attr.out-code = ?.
      end.
    END .
    FOR EACH ub.chk-gds-pay WHERE
             ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code :
      delete ub.chk-gds-pay.
    END .
    FOR EACH ub.c-chk-gds WHERE
              ub.c-chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-gds.
      end.
      else do:
        ub.c-chk-gds.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-pay WHERE
              ub.c-chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-pay.
      end.
      else do:
        ub.c-chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-discnt WHERE
              ub.c-chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-discnt.
      end.
      else do:
        ub.c-chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-doc-attr WHERE
              ub.c-chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc-attr.
      end.
    END .
    FOR EACH ub.c-chk-doc WHERE
              ub.c-chk-doc.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc.
      end.
      else do:
        ub.c-chk-doc.out-code = ? .
      end.
    END .
    if g#news then do:
      delete ub.chk-doc.
    end.
    else do:
      assign
      ub.chk-doc.out-code = ?
      ii = ii + 1
      .
    end.
        .
END .
end.
