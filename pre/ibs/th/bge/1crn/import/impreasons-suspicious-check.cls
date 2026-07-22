using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impreasons-suspicious-check implements ibs.th.bge.1crn.import.iimpsubject:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define buffer buf_code for ub.code .
    define variable v-code as character no-undo .
    define property Msg as character no-undo
        get.
        set.
    method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
        define variable ri        as recid no-undo .
        define variable objReason as class reasons-suspicious-check no-undo.
        objReason = cast (subjectObj, reasons-suspicious-check).
        if objReason:code_ = "" or objReason:code_ = ? then
        do:
            Msg = "Причина подозрительных чеков не задана".
            return error Msg .
        end.
        if objReason:name_ = "" or objReason:name_ = ? then
        do:
            Msg = "Причина подозрительных чеков с кодом " + objReason:code_ + ". Не задано наименование" .
            return error Msg .
        end.
        find first buf_code where buf_code.parent eq ""
            and buf_code.code   eq 'reasons-suspicious-check':U
            exclusive-lock no-error.
        if not available buf_code
            then
        do:
            create buf_code.
            assign
                buf_code.parent = ""
                buf_code.code   = 'reasons-suspicious-check':U
                .
        end.
        assign
            buf_code.Codename = 'Справочник "Причины подозрительных чеков"'
            buf_code.nwsgbd   = yes
            buf_code.export_  = yes
            buf_code.procview = ""
            .
        find first buf_code exclusive-lock where buf_code.code = objReason:code_
            and buf_code.parent = 'reasons-suspicious-check':U
            no-error .
        if available buf_code
            then
        do:
            delete buf_code .
        end .
        create buf_code .
        assign
            buf_code.parent   = 'reasons-suspicious-check':U
            buf_code.code     = objReason:code_
            buf_code.CodeName = objReason:name_
            buf_code.status_  = objReason:del-l
            .
    end method.
end class.
