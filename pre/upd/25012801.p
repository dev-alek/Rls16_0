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
define buffer db for ub.db.
define buffer thbj-attr for ub.thbj-attr.
if g#db-num eq 0
then do:
   for each db no-lock:
      do trans:
      for each thbj-attr where thbj-attr.upper-prop-code eq 'gisMT':U
                           and thbj-attr.obj-type        eq 'ад':U
                           and thbj-attr.obj-code        eq db.db-num
                           and thbj-attr.prop-code       ne ""
                           and thbj-attr.prop-code       ne 'OflineAdress':U
                           and thbj-attr.prop-code       ne 'OflineLogin':U
                           and thbj-attr.prop-code       ne 'OflinePswd':U
                           and thbj-attr.prop-code       ne 'adressPort':U
                           and thbj-attr.prop-code       ne 'dopParam':U
                           and thbj-attr.prop-code       ne 'gisAdress':U
                           and thbj-attr.prop-code       ne 'proxyLogin':U
                           and thbj-attr.prop-code       ne 'proxyPswd':U
                           and thbj-attr.prop-code       ne 'regKey':U
                           and thbj-attr.prop-code       ne 'waitTime':U
                           and thbj-attr.prop-code       ne 'cdnTurnOn':U
                           and thbj-attr.prop-code       ne 'cdnAdress':U
                           and thbj-attr.prop-code       ne 'crashSituat':U
      exclusive-lock:
            delete thbj-attr.
      end.
      end.
   end.
end.
oOk = true.
