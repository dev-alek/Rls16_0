 
 /*------------------------------------------------------------------------
    File        : ReportXml
    Purpose     : Класс для создания отчетов в xml для дальнейшего преобразования их с помощью XSLT
    Syntax      : 
    Description : 
    Author(s)   : SKiryxin
    Created     : Fri Jul 20 13:45:40 MSD 2012
    Notes       : Инструкция:
                  1   new ReportXml(xml_tmp)        + (начало отчета)
                  2   worksheet("Лист 1")           + (начало листа)
                  3   worksheet-header("start")     + (заголовок листа)
                  4   worksheet-header()            + (заголовок листа)
                  5   worksheet-header("end")       + (заголовок листа)
                  6   table-columns                 + (размер столбцов) (открывает тэг таблицы) (*0.75 для перевода в px)
                  7   table-types                   + (типы данных столбцов (задать переменную))
                  8   table-header("а|б|в","25","3")+ (заголовок таблицы) (пока без объединения ячеек)
                  9   table-group                   + (название группы)
                 10   table-row                     + (строка данных)
                 11   table-subtotal                + (итог по группе)
                 12   table-total                   + (итого) (закрывает тэг таблицы)
                 13   worksheet-footer              + (подвал листа) (аналогичен header)
                 14   worksheet("end")              + (закрытие листа)
                 15   delete object ReportXml       + (закрытие отчета) (вместо ReportXml писать переменную, заведенную под класс)

               доп.   add-element("test","1")       + (добавляет элемент со значением)
               доп.   start-element("name")         + (открыть тэг)
               доп.   add-attr(name, value)         + (вставить атрибут)
               доп.   end-element("name")           + (закрыть тэг)

                * Все списки должны быть без пробелов, сразу ставить разделитель.
                  Числовые значения (например количества) нужно округлять сразу.
  ----------------------------------------------------------------------*/
using Progress.Lang.*.
block-level on error undo, throw.

class Ibs.Th.Gbl.ReportXml: 

    define public variable hSAXWriter as handle no-undo. /* для создания excel */
    define public variable table-types as character no-undo.  /* типы столбцов (возможные значения String,Numeric,Money)*/
    define public variable subtotal-types as character no-undo.
    define public variable total-types as character no-undo.    

    /*------------------------------------------------------------------------------
            Purpose: Конструктор
            Notes:   Начинает xml файл
    ------------------------------------------------------------------------------*/
    constructor public ReportXml (input xml_tmp as character):
        super ().
        create sax-writer hSAXWriter.

        hSAXWriter:formatted = true.
        hSAXWriter:encoding = "UTF-8":U.

        hSAXWriter:set-output-destination("file":U, xml_tmp).
        hSAXWriter:start-document().
        hSAXWriter:start-element("Workbook":U). 
    end constructor.

    /*------------------------------------------------------------------------------
            Purpose: Worksheet - лист отчета.
            Notes:   Необходим, если отчет должен быть на несколько закладок excel
                     ! - Входные параметры - Название закладки или end, start не нужен. 
    ------------------------------------------------------------------------------*/
    method public void worksheet(input cName as character):

        if cName = "end":U then do:
            hSAXWriter:end-element("Worksheet":U).
        end.

        else do:
            hSAXWriter:start-element("Worksheet":U).
            hSAXWriter:insert-attribute("Name":U, cName).
        end.

    end method. /* worksheet */

    /*------------------------------------------------------------------------------
            Purpose: Заголовок листа отчета
            Notes:   Метод добавляет строки над таблицей с данными
    ------------------------------------------------------------------------------*/
    method public void worksheet-header(input cHeader as character):

        case cHeader:

        when "start" then
        hSAXWriter:start-element("header":U).

        when "end" then
        hSAXWriter:end-element("header":U).

        otherwise
        hSAXWriter:write-data-element("row":U, cHeader).

        end case.

    end method. /* worksheet-header */

    /*------------------------------------------------------------------------------
            Purpose: Подвал отчета
            Notes:   На всякий случай
    ------------------------------------------------------------------------------*/
    method public void worksheet-footer(input cHeader as character):

        case cHeader:

        when "start" then
        hSAXWriter:start-element("footer":U).

        when "end"   then
        hSAXWriter:end-element("footer":U).

        otherwise
        hSAXWriter:write-data-element("row":U, cHeader).

        end case.

    end method. /* worksheet-header */

    /*------------------------------------------------------------------------------
            Purpose: Устанавливает размер столбцов
            Notes:   Через запятую без пробелов
    ------------------------------------------------------------------------------*/
    method public void table-columns(input cWidth as character):

        define variable i as integer no-undo.

        hSAXWriter:start-element("table":U). /* Здесь начинается таблица */
        hSAXWriter:start-element("columns":U).

        do i = 1 to num-entries(cWidth, ","):
            hSAXWriter:write-data-element("width":U, entry(i, cWidth, ",")).
        end.

        hSAXWriter:end-element("columns":U).     

    end method. /* table-columns */

    /*------------------------------------------------------------------------------
            Purpose: Устанавливает названия столбцов таблицы
            Notes:   Входные параметры - колонки через разделитель, высота строки, номер строки в листе excel (для сквозной строки)
                    (в будущем можно будет объединять поля)
    ------------------------------------------------------------------------------*/
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

    end method. /* table-header */

    /*------------------------------------------------------------------------------
            Purpose: Начинает новую группу
            Notes:   Выдаём название группы и объединяем все ячейки в одну.
    ------------------------------------------------------------------------------*/
    method public void table-group(input cGroup as character):

        hSAXWriter:start-element("row":U).
            hSAXWriter:insert-attribute("Type":U,"group":U).
            hSAXWriter:write-data-element("Name":U, cGroup).
            hSAXWriter:write-data-element("Merge":U, string( num-entries(table-types, ",") - 1 )).
        hSAXWriter:end-element("row":U).          

    end method. /* table-group */

    /*------------------------------------------------------------------------------
            Purpose: Записывает строку в xml файл
            Notes:   
                     Методу выдается строка со специальным разделителем - "|" (без кавычек) 
                     разделитель выбран так, чтобы гарантирована в полях не было такого символа.
                     
                     Метод сам вписывает стиль и тип строчки. (стиль в разработке)
    ------------------------------------------------------------------------------*/
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

    end method.  /* table-row */

    /*------------------------------------------------------------------------------
            Purpose: Записывает итог группы
            Notes:   
    ------------------------------------------------------------------------------*/
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

    end method. /* table-subtotal */

    /*------------------------------------------------------------------------------
            Purpose: Записывает итог отчета
            Notes: 
    ------------------------------------------------------------------------------*/
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

    end method. /* table-total */

    /*------------------------------------------------------------------------------
            Purpose: Начать произвольный элемент
            Notes:   
    ------------------------------------------------------------------------------*/
    method public void start-element(input cName as character):

        hSAXWriter:start-element(cName).

    end method. /* start-element */

    /*------------------------------------------------------------------------------
            Purpose: Закрыть произвольный элемент
            Notes:   
    ------------------------------------------------------------------------------*/
    method public void end-element(input cName as character):

        hSAXWriter:end-element(cName).

    end method. /* end-element */
    
    /*------------------------------------------------------------------------------
            Purpose: Добавить произвольный элемент
            Notes:   
    ------------------------------------------------------------------------------*/
    method public void add-element(input cName as character, input cValue as character):

        hSAXWriter:write-data-element(cName, cValue).

    end method. /* add-element */    

    /*------------------------------------------------------------------------------
            Purpose: Добавить атрибут в текущий элемент
            Notes:   
    ------------------------------------------------------------------------------*/
    method public void add-attr(input cName as character, input cValue as character):

        hSAXWriter:insert-attribute(cName, cValue).

    end method. /* add-element */    

    /*------------------------------------------------------------------------------
            Purpose: Деструктор
            Notes:   Закрывает файл отчета
    ------------------------------------------------------------------------------*/
    destructor public ReportXml ():
        
       hSAXWriter:end-element("Workbook":U).
       hSAXWriter:end-document().
       
       delete object hSAXWriter.
       
    end destructor.

end class.