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
define temp-table x_thbj-attr no-undo like ub.thbj-attr.
function ThbjattrCr return logical
    (input p-prop-code as character,
     input p-prop-val as character,
     input p-prop-type as character):
    define variable vOk as logical no-undo.
    define buffer buf_thbj-attr for ub.thbj-attr.
    vOk = true.
    for each x_thbj-attr:
        if not can-find( first buf_thbj-attr no-lock where
                               buf_thbj-attr.upper-prop-code eq 'gisMT':U
                           and buf_thbj-attr.obj-type        eq x_thbj-attr.obj-type
                           and buf_thbj-attr.obj-code        eq x_thbj-attr.obj-code
                           and buf_thbj-attr.prop-code       eq p-prop-code
                       )
        then do:
           create buf_thbj-attr.
           assign
              buf_thbj-attr.obj-type = x_thbj-attr.obj-type
              buf_thbj-attr.obj-code  = x_thbj-attr.obj-code
              buf_thbj-attr.upper-prop-code = 'gisMT':U
              buf_thbj-attr.prop-code = p-prop-code
              buf_thbj-attr.prop-value-type = p-prop-type
              no-error.
           if avail buf_thbj-attr then
           case p-prop-type:
               when "character"
                  then buf_thbj-attr.property-value-character = p-prop-val.
               when "decimal"
                  then  buf_thbj-attr.property-value-decimal = decimal(p-prop-val).
               when "logical"
                  then  buf_thbj-attr.property-value-logical = logical(p-prop-val).
           end.
        end.
    end.
    return vOk.
end.
PROCEDURE ObjCodeList:
   define buffer buf_thbj-attr for ub.thbj-attr.
   for each buf_thbj-attr no-lock where
            buf_thbj-attr.upper-prop-code = 'gisMT':U
        and buf_thbj-attr.prop-code       = '' :
      if (g#db-num = 0 and
          (buf_thbj-attr.obj-type = 'ад':U or
          (buf_thbj-attr.obj-type = "" and buf_thbj-attr.obj-code = 0)))
          or
          (g#db-num <> 0 and
           buf_thbj-attr.obj-type = 'ад':U and
           buf_thbj-attr.obj-code = g#db-num)
      then do:
          find first x_thbj-attr where
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .
          if not available x_thbj-attr then do:
            create  x_thbj-attr.
            buffer-copy buf_thbj-attr to X_thbj-attr.
          end.
      end.
   end.
END PROCEDURE.
run ObjCodeList.
oOk = ThbjattrCr('MaxApiToken':U,"","character").
if oOk then
oOk = ThbjattrCr ('AgeConfirm':U,"0","integer").
