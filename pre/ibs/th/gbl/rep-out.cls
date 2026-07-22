using Progress.Lang.*.
block-level on error undo, throw.
class Ibs.Th.Gbl.rep-out:
        method public character xsl-transform(input xml as character, input xsl as character):
                define variable result_xml as character no-undo.
        define variable java       as character no-undo.
        define variable saxon      as character no-undo.
        java = search("jre\bin\java.exe":U).
        if java = ? then do:
            message "Не найден исполняющий файл Java." view-as alert-box error  buttons ok.
            return result_xml.
        end.
        saxon = search("exe\saxon.jar":U).
        if saxon = ? then do:
            message "Не найден файл Saxon.jar." view-as alert-box error buttons ok.
            return result_xml.
        end.
        result_xml = session:temp-directory + "result.xml".
        define variable test as character no-undo.
        test = java + " -jar " + saxon + " -o " + result_xml + " " + xml + " " + xsl.
        os-command silent value(java + " -jar " + saxon + " -o " + result_xml + " " + xml + " " + xsl).
        result_xml = search(result_xml).
                return result_xml.
        end method.
        method public void office(input xml as character, input xsl as character):
        define variable ch_office as com-handle no-undo.
        define variable xml_res as character no-undo.
        create "Excel.Application":U ch_office no-error.
      if error-status :error then
      do:
         message
            "Ошибка при запуске Excel" skip
            error-status :get-message(1) skip
            view-as alert-box error .
         undo, return error .
      end.
        if integer(ch_office) <> ? then do:
            xml_res = xsl-transform(xml, xsl).
            if xml_res = ? or xml_res = "" then do:
                message "Файл отчета не создан." view-as alert-box error buttons ok.
                return.
            end.
            ch_office:Visible = false.
            ch_office:DisplayAlerts = false.
            ch_office:Workbooks:open(xml_res).
            ch_office:ActiveWorkBook:SaveAs(string(session:temp-directory + "rep_" + replace(replace(string(now,"99.99.99 HH:MM:SS"),":","-")," ","_") + ".xls"), -4143, , , , , ).
            ch_office:Visible = true.
            ch_office:DisplayAlerts = true.
            release object ch_office no-error.
        end.
        else do:
            create "com.sun.star.ServiceManager":U ch_office no-error.
            if integer(ch_office) = ? then do:
                message "Не найдены Microsoft Excel или Open Office Calc" view-as alert-box.
                return.
            end.
            else do:
                define variable ch_oDocument as com-handle no-undo.
                define variable ch_oDesktop as com-handle no-undo.
                define variable oofilename as character no-undo.
                define variable ooargs as raw no-undo.
                oofilename = "file:///":U + session:temp-directory + "rep_" + replace(replace(string(now,"99.99.99 HH:MM:SS":U),":","-")," ","_") + ".ods".
                assign
                oofilename = replace(oofilename, "\", "/").
                create "com.sun.star.ServiceManager":U ch_office no-error.
                ch_oDesktop  = ch_office:createinstance("com.sun.star.frame.Desktop":U).
                ch_oDocument = ch_oDesktop:loadComponentFromURL(string("file:///":U + replace(xml_res, "\", "/")), "_blank":U, 0,ooargs).
                ch_oDocument:storeAsURL(oofilename,ooargs).
                release object ch_oDesktop no-error.
                release object ch_oDocument no-error.
            end.
        end.
    release object ch_office no-error.
    os-delete value(xml).
    os-delete value(xml_res).
        end method.
end class.
