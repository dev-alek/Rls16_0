
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



define temp-table tt-act-header{4}
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field type_         as character        label "Основание списания" format "X(18)"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.

define temp-table tt-gds-act{4}
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code
.

define {2} {3} temp-table tt-marks{4}
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

define variable sw{4} as handle no-undo .

define variable v-file{4}              as character no-undo initial "ActWriteOff_Shop1.xml".

DEFINE VARIABLE hDoc{4} AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot{4} AS HANDLE NO-UNDO.
DEFINE VARIABLE good{4} AS LOGICAL NO-UNDO.

procedure makeXML{4} :
    create sax-writer sw{4} .
    
    sw{4}:formatted = true.
    sw{4}:set-output-destination ("file", v-file{4}).
    sw{4}:encoding = "UTF-8".
    sw{4}:start-document () .
    sw{4}:start-element ("ns:Documents") .
    sw{4}:insert-attribute ("Version", "1.0") .
    sw{4}:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw{4}:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw{4}:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw{4}:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOff") .
        sw{4}:start-element ("ns:Owner") . 
            sw{4}:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw{4}:end-element ("ns:Owner") . 
        sw{4}:start-element ("ns:Document") .
            sw{4}:start-element ("ns:ActWriteOff") .
                sw{4}:write-data-element ("awr:Identity", tt-act-header{4}.num) no-error .
                sw{4}:start-element ("awr:Header") .
                    sw{4}:write-data-element ("awr:ActNumber", tt-act-header{4}.num) no-error .
                    sw{4}:write-data-element ("awr:ActDate", string(iso-date(tt-act-header{4}.date_))) no-error .
                    sw{4}:write-data-element ("awr:TypeWriteOff", tt-act-header{4}.type_) no-error .
                    sw{4}:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                sw{4}:end-element ("awr:Header") .
                sw{4}:start-element ("awr:Content") .
    for each tt-gds-act{4} no-lock where tt-gds-act{4}.num = tt-act-header{4}.num :
                    sw{4}:start-element ("awr:Position") .
                        sw{4}:write-data-element ("awr:Identity", string(tt-gds-act{4}.position_)) no-error .
                        sw{4}:write-data-element ("awr:Quantity", string(tt-gds-act{4}.qnty)) no-error .
                        sw{4}:write-data-element ("gds-code", string(tt-gds-act{4}.gds-code)) no-error .
                        sw{4}:write-data-element ("gds-name", tt-gds-act{4}.gds-name) no-error .
                        sw{4}:write-data-element ("alc-code", tt-gds-act{4}.alc-code) no-error .
                        sw{4}:start-element ("awr:MarkCodeInfo") .
            for each tt-marks{4} no-lock where tt-marks{4}.num = tt-gds-act{4}.num and tt-marks{4}.gds-part-position_ = tt-gds-act{4}.position_ :
                            sw{4}:write-data-element ("awr:MarkCode", tt-marks{4}.mark) .
            end.    
                        sw{4}:end-element ("awr:MarkCodeInfo") .
                    sw{4}:end-element ("awr:Position") .                
    end. 
                sw{4}:end-element ("awr:Content") .
            sw{4}:end-element ("ns:ActWriteOff") .
        sw{4}:end-element ("ns:Document") .
    sw{4}:end-element ("ns:Documents") .
    sw{4}:end-document () .
    delete object sw{4}.
    
end procedure .


procedure makeXMLegais_v2{4} :
    create sax-writer sw{4} .
    
    sw{4}:formatted = true.
    sw{4}:set-output-destination ("file", v-file{4}).
    sw{4}:encoding = "UTF-8".
    sw{4}:start-document () .
    sw{4}:start-element ("ns:Documents") .
    sw{4}:insert-attribute ("Version", "1.0") .
    sw{4}:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw{4}:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw{4}:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef_v2") .
    sw{4}:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw{4}:insert-attribute ("xmlns:awr", "http://fsrar.ru/WEGAIS/ActWriteOffShop_v2") .
    sw{4}:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw{4}:start-element ("ns:Owner") . 
            sw{4}:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw{4}:end-element ("ns:Owner") . 
        sw{4}:start-element ("ns:Document") .
            sw{4}:start-element ("ns:ActWriteOffShop_v2") .
                sw{4}:write-data-element ("awr:Identity", tt-act-header{4}.num) .
                sw{4}:start-element ("awr:Header") .
                    sw{4}:write-data-element ("awr:ActNumber", tt-act-header{4}.num) .
                    sw{4}:write-data-element ("awr:ActDate", string(iso-date(tt-act-header{4}.date_))) no-error .
                    sw{4}:write-data-element ("awr:Note", "Необходимо списать товарные позиции с баланса") .
                    sw{4}:write-data-element ("awr:TypeWriteOff", tt-act-header{4}.type_) .
                sw{4}:end-element ("awr:Header") .
                sw{4}:start-element ("awr:Content") .
    for each tt-gds-act{4} no-lock where tt-gds-act{4}.num = tt-act-header{4}.num :
        if tt-gds-act{4}.qnty <= 0 then next. 
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
                    if not available buf_goods and (tt-gds-act.gds-code = 0 or tt-gds-act.gds-code =?)
                    then do :
                        find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods}
                                                               and X_ext-classif.classif-name = {&extclass_goods_esys}
                                                               and X_ext-classif.db-num = 0
                                                               and X_ext-classif.Key#_two = v-ext-sys
                                                               and X_ext-classif.Key#_three = 0
                                                               and X_ext-classif.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif.CharKey_two = ""
                                                               and X_ext-classif.CharKey_three = ""
                                                               and X_ext-classif.nonunique = 0
                                                               no-error .
                        if available X_ext-classif
                        then do :
                            tt-gds-act.gds-code = X_ext-classif.Key#_One .
                            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code . 
                        end.                                       
                    end.
                    sw{4}:start-element ("awr:Position") .
                        sw{4}:write-data-element ("awr:Identity", string(tt-gds-act{4}.position_)) .
                        sw{4}:start-element ("awr:Product") .
                            sw{4}:write-data-element ("pref:UnitType", (if buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1 then "Unpacked" else "Packed")) . 
                            sw{4}:write-data-element ("pref:FullName", tt-gds-act{4}.egais-name) no-error .
                            sw{4}:write-data-element ("pref:ShortName", "") . 
                            sw{4}:write-data-element ("pref:AlcCode", tt-gds-act{4}.alc-code) .
                            if not (buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1)
                            then sw{4}:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) . 
                            sw{4}:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) . 
                            
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw{4}:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
                        end.
                        
                        find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = {&table_goods}
                                                               and X_ext-classif-attr.classif-name = {&extclass_goods_esys}
                                                               and X_ext-classif-attr.db-num = 0
                                                               and X_ext-classif-attr.Key#_One = tt-gds-act.gds-code
                                                               and X_ext-classif-attr.Key#_two = v-ext-sys
                                                               and X_ext-classif-attr.Key#_three = 0
                                                               and X_ext-classif-attr.CharKey_One = tt-gds-act.alc-code
                                                               and X_ext-classif-attr.CharKey_two = ""
                                                               and X_ext-classif-attr.CharKey_three = ""
                                                               and X_ext-classif-attr.nonunique = 0
                                                               and X_ext-classif-attr.attr-code = 'egais-info'
                                                               no-error .                
                        if available X_ext-classif-attr and num-entries(X_ext-classif-attr.attr-value, CHR(4)) >= 3 then do : 
                          def var v-prod as char no-undo.
                          def var v-impor as char no-undo.
                          def var v-msg as char no-undo.
                          def var v-err as logical no-undo.
                          def var v-err-impor as logical no-undo.
                          v-err = false .
                          v-prod = ''.
                          v-impor = ''.
                          
                          
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 8
                          or entry (7, v-prod, chr(5)) = ""
                          then do:
                            message "У товара неизвестен производитель (или его тип) из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.
                            v-err = true .
                          end.
                          
/*                          v-impor = entry (2, X_ext-classif-attr.attr-value, chr(4)) no-error.                                                                                                                           */
/*                          if (num-entries (v-impor, chr (5)) > 0 and num-entries (v-impor, chr (5)) < 8)                                                                                                                 */
/*                              or (trim(v-impor) <> "" and entry (7, v-impor, chr(5)) = "")                                                                                                                               */
/*                            then                                                                                                                                                                                         */
/*                          do:                                                                                                                                                                                            */
/*                            message "У товара неверно указан импортер из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD  и  заново сохраните акт." view-as alert-box.*/
/*                            v-err-impor = true .                                                                                                                                                                         */
/*                          end.                                                                                                                                                                                           */
                          
                          if not v-err then do :
                            sw{4}:start-element ("pref:Producer") .
                             sw{4}:start-element ("oref:" + entry (7, v-prod, chr(5))) .
                              if entry (7, v-prod, chr(5)) <> "TS" then do :
                                  if entry (2, v-prod, chr(5)) <> "" then sw{4}:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                                  if entry (3, v-prod, chr(5)) <> "" then sw{4}:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                              end.
                              else if entry (2, v-prod, chr(5)) <> "" then sw{4}:write-data-element ("oref:TSNUM", entry (2, v-prod, chr(5)) ).
                              sw{4}:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                              sw{4}:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                              sw{4}:start-element ("oref:address").
                                sw{4}:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                                if entry (8, v-prod, chr(5)) <> "" then sw{4}:write-data-element ("oref:RegionCode", entry (8, v-prod, chr(5)) ).
                                sw{4}:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                              sw{4}:end-element ("oref:address").
                             sw{4}:end-element ("oref:" + entry (7, v-prod, chr(5))) .
                            sw{4}:end-element ("pref:Producer") .
                          end.  
                          
/*                          if not v-err-impor then do :                                                                                            */
/*                            if trim(v-impor) <> ""                                                                                                */
/*                            and v-impor <> ?                                                                                                      */
/*                            and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5)                                                             */
/*                            and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) then do:                                  */
/*                              sw:start-element ("pref:Importer") .                                                                                */
/*                               sw:start-element ("oref:" + entry (7, v-impor, chr(5))) .                                                          */
/*                                if entry (2, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-impor, chr(5)) ).         */
/*                                if entry (3, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-impor, chr(5)) ).         */
/*                                sw:write-data-element ("oref:ClientRegId", entry (1, v-impor, chr(5)) ).                                          */
/*                                sw:write-data-element ("oref:FullName", entry (4, v-impor, chr(5)) ).                                             */
/*                                sw:start-element ("oref:address").                                                                                */
/*                                  sw:write-data-element ("oref:Country", entry (5, v-impor, chr(5)) ).                                            */
/*                                  if entry (8, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:RegionCode", entry (8, v-impor, chr(5)) ).*/
/*                                  sw:write-data-element ("oref:description", entry (6, v-impor, chr(5)) ).                                        */
/*                                sw:end-element ("oref:address").                                                                                  */
/*                               sw:end-element ("oref:" + entry (7, v-impor, chr(5))) .                                                            */
/*                              sw:end-element ("pref:Importer") .                                                                                  */
/*                            end.                                                                                                                  */
/*                          end.                                                                                                                    */

                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act{4}.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        
                        sw{4}:end-element ("awr:Product") .
                        sw{4}:write-data-element ("awr:Quantity", string(tt-gds-act{4}.qnty)) .
        find first tt-marks{4} where tt-marks{4}.num = tt-gds-act{4}.num and tt-marks{4}.gds-part-position_ = tt-gds-act{4}.position_ no-lock no-error.
        if available tt-marks{4} and (tt-act-header{4}.type_ = "Проверки" or tt-act-header{4}.type_ = "Арест") then do :                
                        sw{4}:start-element ("awr:MarkCodeInfo") .
            for each tt-marks{4} no-lock where tt-marks{4}.num = tt-gds-act{4}.num and tt-marks{4}.gds-part-position_ = tt-gds-act{4}.position_ :
                            sw{4}:write-data-element ("awr:MarkCode", tt-marks{4}.mark) .
            end.    
                        sw{4}:end-element ("awr:MarkCodeInfo") .
        end.         
                    sw{4}:end-element ("awr:Position") .                
    end. 
                sw{4}:end-element ("awr:Content") .
            sw{4}:end-element ("ns:ActWriteOffShop_v2") .
        sw{4}:end-element ("ns:Document") .
    sw{4}:end-element ("ns:Documents") .
    sw{4}:end-document () .
    delete object sw{4}.
    
end procedure .

procedure parseXML{4} :
    
    define input parameter inFile as character no-undo .
    
    empty temp-table tt-act-header{4} .
    empty temp-table tt-gds-act{4} .
    
    CREATE X-DOCUMENT hDoc{4}.
    CREATE X-NODEREF hRoot{4}.
   
    hDoc{4}:encoding = 'utf-8'.
    hDoc{4}:LOAD("file", search(inFile),FALSE).
   
    hDoc{4}:GET-DOCUMENT-ELEMENT(hRoot{4}).
    
    RUN GetChildren{4}(hRoot{4}, 1).

    DELETE OBJECT hDoc{4}.
    DELETE OBJECT hRoot{4}.    
end procedure .

procedure GetChildren{4} :
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
            create tt-act-header{4} .
            assign tt-act-header{4}.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "awr:ActNumber" THEN assign tt-act-header{4}.num    = hText:node-value no-error .
        IF hNoderef:NAME = "awr:ActDate" THEN 
            assign tt-act-header{4}.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .    
        IF hNoderef:NAME = "awr:TypeWriteOff" THEN assign tt-act-header{4}.type_    = hText:node-value no-error .    
        IF hNoderef:NAME = "awr:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act{4} .
            assign tt-gds-act{4}.num = tt-act-header{4}.num .
        end.
        IF hNoderef:NAME = "awr:Identity" THEN assign tt-gds-act{4}.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "awr:Quantity" THEN assign tt-gds-act{4}.qnty = decimal(hText:node-value) no-error . 
        IF hNoderef:NAME = "gds-code"     THEN do :
            assign tt-gds-act{4}.gds-code = integer(hText:node-value) no-error . 
            find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code no-error .
            if available buf_goods then assign tt-gds-act{4}.gds-name = buf_goods.gds-name .
        end.
        if hNoderef:NAME = "gds-name" and trim(tt-gds-act{4}.gds-name) = "" then assign tt-gds-act{4}.gds-name = (hText:node-value) no-error .
        IF hNoderef:NAME = "alc-code"     THEN assign tt-gds-act{4}.alc-code = (hText:node-value) no-error .
        
        IF hNoderef:NAME = "awr:MarkCode" THEN do :
            create tt-marks{4}.
            assign
                tt-marks{4}.num                    = tt-gds-act{4}.num
                tt-marks{4}.gds-part-position_     = tt-gds-act{4}.position_
                tt-marks{4}.mark                   = hText:node-value
                tt-marks{4}.gds-code               = tt-gds-act{4}.gds-code
                tt-marks{4}.gds-name               = tt-gds-act{4}.gds-name
                tt-marks{4}.alc-code               = tt-gds-act{4}.alc-code
                ii = ii + 1.
            . 
            assign tt-gds-act{4}.marks-qnty = ii .   
        end.
             
        run GetChildren{4} (hNoderef, (level + 1)).
        
    END.
    
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
&endif
