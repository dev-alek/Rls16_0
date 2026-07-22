using Progress.Lang.*.
block-level on error undo, throw.
class Ibs.Th.Gbl.ReportXml:
    define public variable hSAXWriter as handle no-undo.
    define public variable table-types as character no-undo.
    define public variable subtotal-types as character no-undo.
    define public variable total-types as character no-undo.
    constructor public ReportXml (input xml_tmp as character):
        super ().
        create sax-writer hSAXWriter.
        hSAXWriter:formatted = true.
        hSAXWriter:encoding = "UTF-8":U.
        hSAXWriter:set-output-destination("file":U, xml_tmp).
        hSAXWriter:start-document().
        hSAXWriter:start-element("Workbook":U).
    end constructor.
    method public void worksheet(input cName as character):
        if cName = "end":U then do:
            hSAXWriter:end-element("Worksheet":U).
        end.
        else do:
            hSAXWriter:start-element("Worksheet":U).
            hSAXWriter:insert-attribute("Name":U, cName).
        end.
    end method.
    method public void worksheet-header(input cHeader as character):
        case cHeader:
        when "start" then
        hSAXWriter:start-element("header":U).
        when "end" then
        hSAXWriter:end-element("header":U).
        otherwise
        hSAXWriter:write-data-element("row":U, cHeader).
        end case.
    end method.
    method public void worksheet-footer(input cHeader as character):
        case cHeader:
        when "start" then
        hSAXWriter:start-element("footer":U).
        when "end"   then
        hSAXWriter:end-element("footer":U).
        otherwise
        hSAXWriter:write-data-element("row":U, cHeader).
        end case.
    end method.
    method public void table-columns(input cWidth as character):
        define variable i as integer no-undo.
        hSAXWriter:start-element("table":U).
        hSAXWriter:start-element("columns":U).
        do i = 1 to num-entries(cWidth, ","):
            hSAXWriter:write-data-element("width":U, entry(i, cWidth, ",")).
        end.
        hSAXWriter:end-element("columns":U).
    end method.
    method public void table-header(input cHeader as character,
                                    input cHeight as character,
                                    input cRow as character):
        define variable i as integer no-undo.
        hSAXWriter:start-element("table-header":U).
        hSAXWriter:insert-attribute("Height":U, cHeight).
        hSAXWriter:insert-attribute("Row":U, cRow).
        do i = 1 to num-entries(cHeader, "|"):
            hSAXWriter:write-data-element("header":U, entry(i, cHeader, "|")).
        end.
        hSAXWriter:end-element("table-header":U).
    end method.
    method public void table-group(input cGroup as character):
        hSAXWriter:start-element("row":U).
            hSAXWriter:insert-attribute("Type":U,"group":U).
            hSAXWriter:write-data-element("Name":U, cGroup).
            hSAXWriter:write-data-element("Merge":U, string( num-entries(table-types, ",") - 1 )).
        hSAXWriter:end-element("row":U).
    end method.
    method public void table-row(input cRow as character):
        define variable i as integer no-undo.
        define variable lOK as logical no-undo.
        hSAXWriter:start-element("row":U).
        do i = 1 to num-entries(cRow, "|"):
            assign
            lOK = hSAXWriter:start-element("cell":U)
            lOK = hSAXWriter:insert-attribute("Type":U,entry(i, table-types, ","))
            lOK = hSAXWriter:write-characters(entry(i, cRow, "|"))
            lOK = hSAXWriter:end-element("cell":U).
        end.
        hSAXWriter:end-element("row":U).
    end method.
    method public void table-subtotal(input cRow as character):
        define variable i as integer no-undo.
        define variable lOK as logical no-undo.
        hSAXWriter:start-element("row":U).
        hSAXWriter:insert-attribute("Type":U,"subtotal":U).
        do i = 1 to num-entries(cRow, "|"):
            assign
            lOK = hSAXWriter:start-element("cell":U)
            lOK = hSAXWriter:insert-attribute("Type":U,entry(i, table-types, ","))
            lOK = hSAXWriter:write-characters(entry(i, cRow, "|"))
            lOK = hSAXWriter:end-element("cell":U).
        end.
        hSAXWriter:end-element("row":U).
    end method.
    method public void table-total(input cRow as character):
        define variable i as integer no-undo.
        define variable lOK as logical no-undo.
        hSAXWriter:start-element("row":U).
        hSAXWriter:insert-attribute("Type":U,"total":U).
        do i = 1 to num-entries(cRow, "|"):
            assign
            lOK = hSAXWriter:start-element("cell":U)
            lOK = hSAXWriter:insert-attribute("Type":U,entry(i, table-types, ","))
            lOK = hSAXWriter:write-characters(entry(i, cRow, "|"))
            lOK = hSAXWriter:end-element("cell":U).
        end.
        hSAXWriter:end-element("row":U).
        hSAXWriter:end-element("table":U).
    end method.
    method public void start-element(input cName as character):
        hSAXWriter:start-element(cName).
    end method.
    method public void end-element(input cName as character):
        hSAXWriter:end-element(cName).
    end method.
    method public void add-element(input cName as character, input cValue as character):
        hSAXWriter:write-data-element(cName, cValue).
    end method.
    method public void add-attr(input cName as character, input cValue as character):
        hSAXWriter:insert-attribute(cName, cValue).
    end method.
    destructor public ReportXml ():
       hSAXWriter:end-element("Workbook":U).
       hSAXWriter:end-document().
       delete object hSAXWriter.
    end destructor.
end class.
