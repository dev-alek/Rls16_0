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
function ChgV1 return logical
    (input p-obj-type as char,
     input p-obj-code as int):
    define variable vOk as logical no-undo.
    define buffer thbj-attr for ub.thbj-attr.
    do trans:
        vOk = true.
        find first thbj-attr where thbj-attr.upper-prop-code eq 'gisMT':U
                             and thbj-attr.obj-type        eq p-obj-type
                             and thbj-attr.obj-code        eq p-obj-code
                             and thbj-attr.prop-code       eq 'OflineAdress':U
        exclusive-lock no-wait no-error.
        if available thbj-attr then do:
           if R-INDEX(thbj-attr.property-value-character,"/v1") > 0
           then do:
              thbj-attr.property-value-character = substring(thbj-attr.property-value-character, 1, R-INDEX(thbj-attr.property-value-character,"/v1") ) + "v2" .
           end.
        end.
        else if locked thbj-attr then vOk = false.
    end.
    return vOk.
end.
oOk = ChgV1('ад':U,g#db-num).
if oOk and g#db-num = 0 then oOk = ChgV1("",g#db-num).
