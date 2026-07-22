block-level on error undo, throw.
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
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.
define buffer buf_thbj-attr for thbj-attr.
if g#db-num eq 0
then do:
   for each db no-lock:
      find first thbj-attr where thbj-attr.upper-prop-code eq 'gisMT':U
                           and thbj-attr.obj-type        eq 'ад':U
                           and thbj-attr.obj-code        eq db.db-num
                           and thbj-attr.prop-code       ne ""
      no-lock no-error.
      if avail thbj-attr then do:
         find first thbj-attr where thbj-attr.upper-prop-code eq 'gisMT':U
                           and thbj-attr.obj-type        eq 'ад':U
                           and thbj-attr.obj-code        eq db.db-num
                           and thbj-attr.prop-code       eq 'crashSituat':U
            no-lock no-error.
         if not avail thbj-attr then do:
            find first buf_thbj-attr where buf_thbj-attr.upper-prop-code eq 'gisMT':U
                           and buf_thbj-attr.obj-type    eq ""
                           and buf_thbj-attr.obj-code    eq 0
                           and buf_thbj-attr.prop-code   eq 'crashSituat':U
               no-lock no-error.
            if avail buf_thbj-attr then do:
                do transaction:
                    create thbj-attr.
                    assign
                       thbj-attr.obj-type = 'ад':U
                       thbj-attr.obj-code = db.db-num
                       .
                    buffer-copy buf_thbj-attr except obj-type obj-code to thbj-attr.
                end.
            end.
         end.
      end.
   end.
end.
oOk = true.
