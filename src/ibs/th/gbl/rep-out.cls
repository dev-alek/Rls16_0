 
 /*------------------------------------------------------------------------
    File        : rep-out
    Purpose     : Вывод отчетов в Excel, OpenOffice Calc, html, pdf, print
    Syntax      : 
    Description : 
    Author(s)   : SKiryxin
    Created     : Sat Sep 29 11:08:46 MSD 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class Ibs.Th.Gbl.rep-out: 

	/*------------------------------------------------------------------------------
			Purpose: xsl преобразование 																	  
			Notes:   (через saxon.jar, который идёт стандартно с прогрессом (в версиях 10.1 и 10.2)) 																	  
	------------------------------------------------------------------------------*/

	method public character xsl-transform(input xml as character, input xsl as character):
		
		define variable result_xml as character no-undo.      /* Возвращаемый путь, если всё нормально */
        define variable java       as character no-undo.    /* Путь к Java */
        define variable saxon      as character no-undo.    /* Путь к Saxon.jar */

        /* Сначала найдём все файлы */
        
        /* Сама Java (вроде всегда там лежит) */
        
        java = search("jre\bin\java.exe":U). /* Была проблема с x64 версией и Java от Progress 9 */
        
        if java = ? then do:
            message "Не найден исполняющий файл Java." view-as alert-box error  buttons ok.
            return result_xml.
        end.
        
        /* Saxon.jar */
        
        saxon = search("exe\saxon.jar":U).  /* Проверим exe */

        if saxon = ? then do:
            message "Не найден файл Saxon.jar." view-as alert-box error buttons ok.
            return result_xml.
        end.
        
        /* Если всё нормально, то делаем преобразование */
        
        result_xml = session:temp-directory + "result.xml".
        
        define variable test as character no-undo.
        test = java + " -jar " + saxon + " -o " + result_xml + " " + xml + " " + xsl.
        
        os-command silent value(java + " -jar " + saxon + " -o " + result_xml + " " + xml + " " + xsl).
        
        result_xml = search(result_xml).
        
		return result_xml.

	end method. /* xsl-transform */

	/*------------------------------------------------------------------------------
			Purpose: Вывод отчета в Excel / Openoffice 																	  
			Notes:   Ищет что установлено, Excel или OpenOffice и выводит туда																	  
	------------------------------------------------------------------------------*/

	method public void office(input xml as character, input xsl as character):

        define variable ch_office as com-handle no-undo. /* Для обращения с Excel / OO */
        define variable xml_res as character no-undo. /* Отформатированная xml, которую пересохраняем в нужный формат */
        create "Excel.Application":U ch_office no-error.
      if error-status :error then 
      do:
         message
            "Ошибка при запуске Excel" skip
            error-status :get-message(1) skip
            view-as alert-box error .
         undo, return error .
      end.
        if integer(ch_office) <> ? then do:  /* Если нашли Excel */
            
            xml_res = xsl-transform(xml, xsl).
            
            if xml_res = ? or xml_res = "" then do:
                message "Файл отчета не создан." view-as alert-box error buttons ok.
                return.
            end.
            
            ch_office:Visible = false.
            ch_office:DisplayAlerts = false. /* Иногда выдаёт ошибку формата, но всё корректно */
            ch_office:Workbooks:open(xml_res).
            ch_office:ActiveWorkBook:SaveAs(string(session:temp-directory + "rep_" + replace(replace(string(now,"99.99.99 HH:MM:SS"),":","-")," ","_") + ".xls"), -4143, , , , , ).
            ch_office:Visible = true.
            ch_office:DisplayAlerts = true.
            release object ch_office no-error.
            
        end. /* if integer(ch_office) <> ? */
        
        else do: /* Ищем OpenOffice */
        
            create "com.sun.star.ServiceManager":U ch_office no-error.
        
            if integer(ch_office) = ? then do: /* Если не найден.то говорим и выходим */
                message "Не найдены Microsoft Excel или Open Office Calc" view-as alert-box.
                return.
            end. /* if integer(ch_office) = ? */
            
            else do: /* Значит нашли OO (может получится получше написать эту часть) */
                
                define variable ch_oDocument as com-handle no-undo. 
                define variable ch_oDesktop as com-handle no-undo. 
                define variable oofilename as character no-undo.
                define variable ooargs as raw no-undo.
                
                oofilename = "file:///":U + session:temp-directory + "rep_" + replace(replace(string(now,"99.99.99 HH:MM:SS":U),":","-")," ","_") + ".ods".
                assign  /* ОО работает как по ссылкам, а не путям windows */
                oofilename = replace(oofilename, "\", "/").
                
                create "com.sun.star.ServiceManager":U ch_office no-error.
                ch_oDesktop  = ch_office:createinstance("com.sun.star.frame.Desktop":U).
                ch_oDocument = ch_oDesktop:loadComponentFromURL(string("file:///":U + replace(xml_res, "\", "/")), "_blank":U, 0,ooargs).
                ch_oDocument:storeAsURL(oofilename,ooargs).
                
                release object ch_oDesktop no-error.
                release object ch_oDocument no-error.
            end. /* else do: */
            
        end. /* else do */
    
    release object ch_office no-error.
    
    /* Почистим всё */
    
    os-delete value(xml).
    os-delete value(xml_res).
    
	end method. /* office */

end class.