
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



define temp-table tt-act-header{2}
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
/*    field type_         as character        label "Основание списания" format "X(18)"*/
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.

define temp-table tt-gds-act{2}
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-B      as character                label "Справка Б"               format "X(20)"
    index pi as primary unique
        position_
    index code
        gds-code
.

&if "{1}" = "proc" &then

define variable sw{2} as handle no-undo .

define variable v-file{2}              as character no-undo initial "TransferToShop1.xml".

DEFINE VARIABLE hDoc{2} AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot{2} AS HANDLE NO-UNDO.
DEFINE VARIABLE good{2} AS LOGICAL NO-UNDO.

procedure makeXML{2} :
    create sax-writer sw{2} .
    
    sw{2}:formatted = true.
    sw{2}:set-output-destination ("file", v-file{2}).
    sw{2}:encoding = "UTF-8".
    sw{2}:start-document () .
    sw{2}:start-element ("ns:Documents") .
    sw{2}:insert-attribute ("Version", "1.0") .
    sw{2}:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw{2}:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
    sw{2}:insert-attribute ("xmlns:c", "http://fsrar.ru/WEGAIS/Common") .
    sw{2}:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw{2}:insert-attribute ("xmlns:tts", "http://fsrar.ru/WEGAIS/TransferToShop") .
        sw{2}:start-element ("ns:Owner") . 
            sw{2}:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw{2}:end-element ("ns:Owner") . 
        sw{2}:start-element ("ns:Document") .
            sw{2}:start-element ("ns:TransferToShop") .
                sw{2}:write-data-element ("tts:Identity", tt-act-header{2}.num) no-error .
                sw{2}:start-element ("tts:Header") .
                    sw{2}:write-data-element ("tts:TransferNumber", tt-act-header{2}.num) no-error .
                    sw{2}:write-data-element ("tts:TransferDate", string(iso-date(tt-act-header{2}.date_))) no-error .
                sw{2}:end-element ("tts:Header") .
                sw{2}:start-element ("tts:Content") .
    for each tt-gds-act{2} no-lock where tt-gds-act{2}.num = tt-act-header{2}.num :
                    sw{2}:start-element ("tts:Position") .
                        sw{2}:write-data-element ("tts:Identity", string(tt-gds-act{2}.position_)) no-error .
                        sw{2}:write-data-element ("tts:Quantity", string(tt-gds-act{2}.qnty)) no-error .
                        sw{2}:write-data-element ("gds-code", string(tt-gds-act{2}.gds-code)) no-error .
                        sw{2}:write-data-element ("gds-name", tt-gds-act{2}.gds-name) no-error .
                        sw{2}:write-data-element ("alc-code", tt-gds-act{2}.alc-code) no-error .
                        sw{2}:start-element ("tts:InformB") .
                            sw{2}:write-data-element ("pref:BRegId", tt-gds-act{2}.inform-B) no-error .    
                        sw{2}:end-element ("tts:InformB") .
                    sw{2}:end-element ("tts:Position") .                
    end. 
                sw{2}:end-element ("tts:Content") .
            sw{2}:end-element ("ns:TransferToShop") .
        sw{2}:end-element ("ns:Document") .
    sw{2}:end-element ("ns:Documents") .
    sw{2}:end-document () .
    delete object sw{2}.
    
end procedure .

procedure makeXMLegais_v2{2} :
    create sax-writer sw{2} .
    
    sw{2}:formatted = true.
    sw{2}:set-output-destination ("file", v-file{2}).
    sw{2}:encoding = "UTF-8".
    sw{2}:start-document () .
    sw{2}:start-element ("ns:Documents") .
    sw{2}:insert-attribute ("Version", "1.0") .
    sw{2}:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw{2}:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
    sw{2}:insert-attribute ("xmlns:c", "http://fsrar.ru/WEGAIS/Common") .
    sw{2}:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw{2}:insert-attribute ("xmlns:tts", "http://fsrar.ru/WEGAIS/TransferToShop") .
        sw{2}:start-element ("ns:Owner") . 
            sw{2}:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw{2}:end-element ("ns:Owner") . 
        sw{2}:start-element ("ns:Document") .
            sw{2}:start-element ("ns:TransferToShop") .
                sw{2}:write-data-element ("tts:Identity", tt-act-header{2}.num) .
                sw{2}:start-element ("tts:Header") .
                    sw{2}:write-data-element ("tts:TransferNumber", tt-act-header{2}.num) .
                    sw{2}:write-data-element ("tts:TransferDate", string(iso-date(tt-act-header{2}.date_))) no-error .
                sw{2}:end-element ("tts:Header") .
                sw{2}:start-element ("tts:Content") .
    for each tt-gds-act{2} no-lock where tt-gds-act{2}.num = tt-act-header{2}.num :
        if tt-gds-act.qnty <= 0 or trim(tt-gds-act.inform-B) = "" or tt-gds-act{2}.inform-B = ? then next. 
                    sw{2}:start-element ("tts:Position") .
                        sw{2}:write-data-element ("tts:Identity", string(tt-gds-act{2}.position_)) .
                        sw{2}:write-data-element ("tts:ProductCode", tt-gds-act{2}.alc-code) no-error .
                        sw{2}:write-data-element ("tts:Quantity", string(tt-gds-act{2}.qnty)) .
                        sw{2}:start-element ("tts:InformF2") .
                          sw{2}:write-data-element ("pref:F2RegId", tt-gds-act{2}.inform-B) .    
                        sw{2}:end-element ("tts:InformF2") .
                    sw{2}:end-element ("tts:Position") .                
    end. 
                sw{2}:end-element ("tts:Content") .
            sw{2}:end-element ("ns:TransferToShop") .
        sw{2}:end-element ("ns:Document") .
    sw{2}:end-element ("ns:Documents") .
    sw{2}:end-document () .
    delete object sw{2}.
    
end procedure .

procedure parseXML{2} :
    
    define input parameter inFile as character no-undo .
    
    empty temp-table tt-act-header{2} .
    empty temp-table tt-gds-act{2} .
    
    CREATE X-DOCUMENT hDoc{2}.
    CREATE X-NODEREF hRoot{2}.
   
    hDoc{2}:encoding = 'utf-8'.
    hDoc{2}:LOAD("file", search(inFile),FALSE).
   
    hDoc{2}:GET-DOCUMENT-ELEMENT(hRoot{2}).
    
    RUN GetChildren{2}(hRoot{2}, 1).

    DELETE OBJECT hDoc{2}.
    DELETE OBJECT hRoot{2}.    
end procedure .

procedure GetChildren{2} :
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
        IF hNoderef:NAME = "tts:Header" THEN do :
            create tt-act-header{2} .
            assign tt-act-header{2}.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value no-error.
        end .
        .
        IF hNoderef:NAME = "tts:TransferNumber" THEN assign tt-act-header{2}.num    = hText:node-value no-error .
        IF hNoderef:NAME = "tts:TransferDate" THEN 
            assign tt-act-header{2}.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .    
        IF hNoderef:NAME = "tts:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act{2} .
            assign tt-gds-act{2}.num = tt-act-header{2}.num .
        end.
        IF hNoderef:NAME = "tts:Identity" THEN assign tt-gds-act{2}.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "tts:Quantity" THEN assign tt-gds-act{2}.qnty = decimal(hText:node-value) no-error . 
        IF hNoderef:NAME = "pref:BRegId"
        OR hNoderef:NAME = "pref:F2RegId" THEN assign tt-gds-act{2}.inform-B = (hText:node-value) no-error .
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act{2}.gds-code = integer(hText:node-value) no-error . 
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act{2}.gds-code no-error .
            if available buf_goods then assign tt-gds-act{2}.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act{2}.gds-name) = "" then assign tt-gds-act{2}.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code" 
        OR hNoderef:NAME = "tts:ProductCode"    THEN assign tt-gds-act{2}.alc-code = (hText:node-value) no-error .
             
        run GetChildren{2} (hNoderef, (level + 1)).
        
    END.
    
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
&endif
