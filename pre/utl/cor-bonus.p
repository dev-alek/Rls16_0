block-level on error undo, throw.
define input  parameter iKey     as integer no-undo.
define output parameter oChekSum as character no-undo.
if userid("ub") eq ""
then do:
   oChekSum = encode(string(iKey * 13)) + string(index(encode(string(iKey)), "k"))
 .
   return.
end.
def input parameter p-type as int.
def input parameter p-obj as int.
def input parameter p-date as date.
disable triggers for load of chk-gds-pay.
if p-type <= 0 then return.
if p-obj = 0 then do:
    for each chk-doc where chk-doc.chk-type = 6
                       and chk-doc.chk-date >= p-date
                       and (   p-type eq ?
                            or can-find(first chk-pay of chk-doc where pay-code = p-type no-lock))
    no-lock:
        for each chk-gds-pay of chk-doc:
            delete chk-gds-pay.
        end.
    end.
    for each chk-doc where chk-doc.chk-type = 1
                       and chk-doc.chk-date >= p-date
                       and (   p-type eq ?
                            or can-find(first chk-pay of chk-doc where pay-code = p-type no-lock) )
     no-lock:
        for each chk-gds-pay of chk-doc:
            delete chk-gds-pay.
        end.
    end.
end.
else do:
    for each chk-doc where chk-doc.chk-type = 6
                       and chk-doc.chk-date >= p-date
                       and chk-doc.obj-type = 'маг'
                       and chk-doc.obj-code = p-obj
                       and (   p-type eq ?
                            or can-find(first chk-pay of chk-doc where pay-code = p-type no-lock))
    no-lock:
        for each chk-gds-pay of chk-doc:
            delete chk-gds-pay.
        end.
    end.
    for each chk-doc where chk-doc.chk-type = 1
                       and chk-doc.chk-date >= p-date
                       and chk-doc.obj-code = p-obj
                       and (   p-type eq ?
                            or can-find(first chk-pay of chk-doc where pay-code = p-type no-lock))
    no-lock:
        for each chk-gds-pay of chk-doc:
            delete chk-gds-pay.
        end.
    end.
end.
