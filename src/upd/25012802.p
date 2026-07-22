block-level on error undo, throw.
{ cmp/trg-def.i  }
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

define buffer buf_thbj-attr for thbj-attr.

if g#db-num eq 0
then do:
   for each db no-lock:
      find first thbj-attr where thbj-attr.upper-prop-code eq {&attr-gisMT}
                           and thbj-attr.obj-type        eq {&db}
                           and thbj-attr.obj-code        eq db.db-num
                           and thbj-attr.prop-code       ne ""                           
      no-lock no-error.
      if avail thbj-attr then do:         
         find first thbj-attr where thbj-attr.upper-prop-code eq {&attr-gisMT}
                           and thbj-attr.obj-type        eq {&db}
                           and thbj-attr.obj-code        eq db.db-num
                           and thbj-attr.prop-code       eq {&attr-gisMT_crashSituat}
            no-lock no-error.
         if not avail thbj-attr then do:
            find first buf_thbj-attr where buf_thbj-attr.upper-prop-code eq {&attr-gisMT}
                           and buf_thbj-attr.obj-type    eq ""
                           and buf_thbj-attr.obj-code    eq 0
                           and buf_thbj-attr.prop-code   eq {&attr-gisMT_crashSituat}                           
               no-lock no-error.
            if avail buf_thbj-attr then do:
                do transaction:
                    create thbj-attr.
                    assign
                       thbj-attr.obj-type = {&db}
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