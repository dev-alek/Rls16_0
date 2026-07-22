{ cmp/str-glbl.i }
define temp-table tt0-goods-attr no-undo like ub.goods-attr
field grp as logical
field fdisable as logical
index attr-code-activ fdisable gds-code attr-code
index attr-code                gds-code attr-code.

procedure addGdsGrpAttr:
   define input  parameter i-gds-code as integer no-undo.
   define input  parameter i-grp-code as integer no-undo.
   define variable vi as integer no-undo.
   define buffer buf_gds-grp-obj-attr for gds-grp-obj-attr.
   define buffer tt0-goods-attr for tt0-goods-attr.
   define buffer buf-goods-attr for tt0-goods-attr.
   for each tt0-goods-attr where tt0-goods-attr.grp:
      delete tt0-goods-attr.
   end.
   do vi = 1 to num-entries({&gds-attr-list}):
      find first buf_gds-grp-obj-attr no-lock
         where buf_gds-grp-obj-attr.node-code   = i-grp-code
           and buf_gds-grp-obj-attr.host-code   = 0
           and buf_gds-grp-obj-attr.obj-type    = ""
           and buf_gds-grp-obj-attr.obj-code    = 0
           and buf_gds-grp-obj-attr.attr-code   = entry(vi,{&gds-attr-list})
      no-error .
      if available buf_gds-grp-obj-attr
      then do:
         find first tt0-goods-attr where tt0-goods-attr.gds-code   = i-gds-code
                                     and tt0-goods-attr.attr-code  = buf_gds-grp-obj-attr.attr-code
                                     and tt0-goods-attr.grp
         no-error.

            create tt0-goods-attr.
         assign
            tt0-goods-attr.gds-code   = i-gds-code
            tt0-goods-attr.attr-code  = buf_gds-grp-obj-attr.attr-code
            tt0-goods-attr.attr-value = buf_gds-grp-obj-attr.attr-value
            tt0-goods-attr.grp        = yes
         .
         tt0-goods-attr.fdisable = can-find (buf-goods-attr where buf-goods-attr.gds-code   eq tt0-goods-attr.gds-code
                                                              and buf-goods-attr.attr-code  eq tt0-goods-attr.attr-code
                                                              and buf-goods-attr.grp        ne yes).
         . 
         end.

   end.
end.