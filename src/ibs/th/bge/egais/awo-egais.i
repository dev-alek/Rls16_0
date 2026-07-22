
/*------------------------------------------------------------------------
    File        : wb-egais.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Fri Nov 27 17:55:35 MSK 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

&glob awo-header 1
&glob awo-answer   2
&glob awo-clob   3



define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field type_         as character        label "Основание списания" format "X(18)"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.

define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-B      as character                label "Справка Б"               format "X(20)"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        num position_
    index code
        gds-code
.

define {2} {3} temp-table tt-marks
    field num                 as character            label "№ акта"
    field gds-part-position_  as integer
    field mark                as character            label "Марка"          format "X(100)"
    field new_                as logical
    field gds-code            like ub.goods.gds-code  LABEL "Код товара"                 
    field gds-name            as character            LABEL "Наименование"   FORMAT "X(30)" 
    field alc-code            as character            LABEL "Алк. код"       FORMAT "X(20)"     
    field impor-full-name     as character            LABEL "Импортер"       FORMAT "X(130)" 
    field prod-full-name      as character            LABEL "Производитель"  FORMAT "X(130)" 
    field flag                as logical              label "T"
    index pi as primary unique
        mark
.

&if "{1}" = "proc" &then

define variable sw as handle no-undo .

define variable v-file              as character no-undo initial "ActWriteOff1.xml".

DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.

procedure makeXML :
    create sax-writer sw .
    
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff") .
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOff") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) no-error .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) no-error .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) no-error .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) no-error .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) no-error .
                        sw:write-data-element ("gds-code", string(tt-gds-act.gds-code)) no-error .
                        sw:write-data-element ("gds-name", tt-gds-act.gds-name) no-error .
                        sw:write-data-element ("alc-code", tt-gds-act.alc-code) no-error .
                        sw:start-element ("awr:InformB") .
                            sw:write-data-element ("pref:BRegId", tt-gds-act.inform-B) no-error .    
                        sw:end-element ("awr:InformB") .
                        sw:start-element ("awr:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("awr:MarkCode", tt-marks.mark) .
            end.    
                        sw:end-element ("awr:MarkCodeInfo") .                        
                    sw:end-element ("awr:Position") .                
    end. 
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOff") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
    
end procedure .

procedure makeXMLegais :
    create sax-writer sw .
    
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff") .
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOff") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 or trim(tt-gds-act.inform-B) = "" or tt-gds-act.inform-B = ? then next. 
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("awr:InformB") .
                            sw:write-data-element ("pref:BRegId", tt-gds-act.inform-B) .    
                        sw:end-element ("awr:InformB") .
                    sw:end-element ("awr:Position") .                
    end. 
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOff") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
    
end procedure .

procedure makeXMLegais_v2 :
    create sax-writer sw .
    
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff_v2") .
    sw:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActWriteOff_v2") .
                sw:write-data-element ("awr:Identity", tt-act-header.num) .
                sw:start-element ("awr:Header") .
                    sw:write-data-element ("awr:ActNumber", tt-act-header.num) .
                    sw:write-data-element ("awr:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("awr:TypeWriteOff", tt-act-header.type_) .
                    sw:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw:end-element ("awr:Header") .
                sw:start-element ("awr:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 or trim(tt-gds-act.inform-B) = "" or tt-gds-act.inform-B = ? then next. 
                    sw:start-element ("awr:Position") .
                        sw:write-data-element ("awr:Identity", string(tt-gds-act.position_)) .
                        sw:write-data-element ("awr:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("awr:InformF1F2") .
                          sw:start-element ("awr:InformF2") .
                            sw:write-data-element ("pref:F2RegId", tt-gds-act.inform-B) .    
                          sw:end-element ("awr:InformF2") .
                        sw:end-element ("awr:InformF1F2") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks and (tt-act-header.type_ = "Проверки" or tt-act-header.type_ = "Арест") then do :                
                        sw:start-element ("awr:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("awr:MarkCode", tt-marks.mark) .
            end.    
                        sw:end-element ("awr:MarkCodeInfo") .
        end.                        
                    sw:end-element ("awr:Position") .                
    end. 
                sw:end-element ("awr:Content") .
            sw:end-element ("ns:ActWriteOff_v2") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
    
end procedure .

procedure parseXML :
    
    define input parameter inFile as character no-undo .
    
    empty temp-table tt-act-header .
    empty temp-table tt-gds-act .
    
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
   
    hDoc:encoding = 'utf-8'.
    hDoc:LOAD("file", search(inFile),FALSE).
   
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    
    RUN GetChildren(hRoot, 1).

    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.    
end procedure .

procedure GetChildren :
    DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
    DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
        
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    
    
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,i).
        IF NOT good THEN 
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        
        hNoderef:GET-CHILD(hText, 1) no-error .    
        
/*        IF hNoderef:NAME = "ns:FSRAR_ID" THEN   */
/*            assign v-FS-RAR = hText:node-value .*/
        IF hNoderef:NAME = "awr:Header" THEN do :
            create tt-act-header .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "awr:ActNumber" THEN assign tt-act-header.num    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:ActDate" THEN 
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .    
        IF hNoderef:NAME = "awr:TypeWriteOff" THEN assign tt-act-header.type_    = hText:node-value no-error .    
        IF hNoderef:NAME = "awr:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "awr:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "awr:Quantity" THEN assign tt-gds-act.qnty = decimal(hText:node-value) no-error . 
        IF hNoderef:NAME = "pref:BRegId"
        OR hNoderef:NAME = "pref:F2RegId" THEN assign tt-gds-act.inform-B = (hText:node-value) no-error .
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act.gds-code = integer(hText:node-value) no-error . 
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if available buf_goods then assign tt-gds-act.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act.gds-name) = "" then assign tt-gds-act.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code"     THEN assign tt-gds-act.alc-code = (hText:node-value) no-error .
        
        IF hNoderef:NAME = "awr:MarkCode" THEN do :
            create tt-marks.
            assign
                tt-marks.num                    = tt-gds-act.num
                tt-marks.gds-part-position_     = tt-gds-act.position_
                tt-marks.mark                   = hText:node-value
                tt-marks.gds-code               = tt-gds-act.gds-code
                tt-marks.gds-name               = tt-gds-act.gds-name
                tt-marks.alc-code               = tt-gds-act.alc-code
                ii = ii + 1.
            . 
            assign tt-gds-act.marks-qnty = ii .   
        end.
             
        run GetChildren (hNoderef, (level + 1)).
        
    END.
    
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
&endif
