
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

&glob ab-header 1
&glob ab-answer   2
&glob ab-clob   3



define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
    field is-sent       as logical
    field answer_       as character        label "Ответ"       format "X(1500)"
    field type_         as character        label "Основание"   format "X(35)"
    field RegID         as character        label "Рег. номер"  format "X(50)"
    index pi as primary unique
        num
.

define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field gds-code      like ub.goods.gds-code      label "Код товара   "
    field part-code     like ub.parts.part-code     label "Партия"
    field doc-code      as character                label "№ накладной TH"
    field doc-date      like ub.trn-doc.fact-date   label "Дата TH"
    field alc-code      as character                label "Алкогольный код"         format "X(21)"
    field gds-name      like ub.goods.gds-name      label "Наименование товара"     format "X(35)"
    field qnty          as decimal                  label "Количество"
    field inform-A      as character                label "Справка А"               format "X(20)"
    field A-qnty        as decimal                  label "Кол-во в справке"        
    field A-bottleDate  as date                     label "Дата розлива"
    field A-ttnNumber   as character                label "№ ТТН справки А"         format "X(15)"
    field A-ttnDate     as date                     label "Дата"
    field A-fixNumber   as character                label "№ фиксации в ЕГАИС"      format "X(20)"
    field A-fixDate     as date                     label "Дата фикс."
    field inform-B      as character                label "Справка Б"               format "X(20)"
    field marks-qnty    as integer                  label "Кол-во марок"
    field egais-name    as character
    index pi as primary unique
        position_
    index code
        gds-code doc-code
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
    field reserv              as integer              label "R"
    field parts               as character            label "Партия"         format "X(130)"
    index pi as primary unique
        mark
.

&if "{1}" = "proc" &then

define variable sw as handle no-undo .

define variable v-file              as character no-undo initial "ActChargeOn1.xml".

DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.

procedure makeXML_TH :
    create sax-writer sw .
    
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:ain", "http://fsrar.ru/WEGAIS/ActChargeOn") .
    sw:insert-attribute ("xmlns:ainp", "http://fsrar.ru/WEGAIS/ActChargeOn_v2") .
    sw:insert-attribute ("xmlns:iab", "http://fsrar.ru/WEGAIS/ActInventoryABInfo") . 
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActChargeOn") . 
                sw:start-element ("ain:Header") .
                    sw:write-data-element ("ain:Number", tt-act-header.num) .
                    sw:write-data-element ("ain:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("ain:Note", "Необходимо поставить товарные позиции на баланс") .
                    if egais:VerXSD = "2"
                    then do :
                        if tt-act-header.type_ <> "Продукция полученная до 01.01.2016"
                        then
                          sw:write-data-element ("ainp:TypeChargeOn", tt-act-header.type_) no-error .
                        else
                          sw:write-data-element ("ainp:TypeChargeOn", "Продукция, полученная до 01.01.2016") no-error .
                    end.
                sw:end-element ("ain:Header") .
                sw:start-element ("ain:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next. 
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                    sw:start-element ("ain:Position") .
                        sw:write-data-element ("ain:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("ain:Product") .
                            sw:write-data-element ("pref:Type", "АП") . 
/*                            run gds-attr-value(       */
/*                                tt-gds-act.gds-code,  */
/*                                {&attr-egais-name},   */
/*                                output par-egais-name,*/
/*                                output par-type       */
/*                            ).                        */
                            sw:write-data-element ("gds-code", string(tt-gds-act.gds-code)) no-error .
                            sw:write-data-element ("gds-name", tt-gds-act.gds-name) no-error . 
                            sw:write-data-element ("doc-code", tt-gds-act.doc-code) no-error .
                            sw:write-data-element ("part-code", tt-gds-act.part-code) no-error .
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") . 
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) . 
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) .
                            
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
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
                          v-prod = ''.
                          v-impor = ''.
                          
                          
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if egais:VerXSD = "1"
                          and (v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 6 )
                          then do:
                            message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.
                          
                          if egais:VerXSD = "2"
                          and (v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 8
                          or entry (7, v-prod, chr(5)) = "" )
                          then do:
                            message "У товара неизвестен производитель (или его тип) из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.
                          end.

                          v-impor = entry (2, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if egais:VerXSD = "1"
                          and num-entries (v-impor, chr (5)) > 0 and num-entries (v-impor, chr (5)) < 6 
                            then 
                          do:
                            message "У товара неверно указан импортер из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.                          
                          
                          sw:start-element ("pref:Producer") .
                            if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                            if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                            sw:start-element ("oref:address").
                              sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                            sw:end-element ("oref:address").
                          sw:end-element ("pref:Producer") .
            
                          if egais:VerXSD = "1"
                          and v-impor <> ""
                          and v-impor <> ?
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) then do:
                            sw:start-element ("pref:Importer") .
                              if entry (2, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-impor, chr(5)) ).
                              if entry (3, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-impor, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-impor, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-impor, chr(5)) ).
                              sw:end-element ("oref:address").
                            sw:end-element ("pref:Importer") .
                          end.

                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        
                        sw:end-element ("ain:Product") .
                        sw:write-data-element ("ain:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("ain:InformAB") .
                            sw:start-element ("ain:InformABReg") . 
                                sw:start-element ("ain:InformA") .
                                    sw:write-data-element ("iab:Quantity", string(tt-gds-act.A-qnty)) no-error .
                                    sw:write-data-element ("iab:BottlingDate", string(iso-date(tt-gds-act.A-bottleDate))) no-error .
                                    sw:write-data-element ("iab:TTNNumber", tt-gds-act.A-ttnNumber) no-error .
                                    sw:write-data-element ("iab:TTNDate", string(iso-date(tt-gds-act.A-ttnDate))) no-error .
                                    if tt-gds-act.A-fixNumber <> ? and trim(tt-gds-act.A-fixNumber) <> "" then do :
                                        sw:write-data-element ("iab:EGAISFixNumber", tt-gds-act.A-fixNumber) no-error .
                                        sw:write-data-element ("iab:EGAISFixDate", string(iso-date(tt-gds-act.A-fixDate))) no-error .
                                    end.
                                sw:end-element ("ain:InformA") .  
                            sw:end-element ("ain:InformABReg") .
                        sw:end-element ("ain:InformAB") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks then do :                
                        sw:start-element ("ain:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("ain:MarkCode", tt-marks.mark) .
            end.    
                        sw:end-element ("ain:MarkCodeInfo") .
        end.         
                    sw:end-element ("ain:Position") .                
    end. 
                sw:end-element ("ain:Content") .
            sw:end-element ("ns:ActChargeOn") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
    
end procedure .

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
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef") .
    sw:insert-attribute ("xmlns:ain", "http://fsrar.ru/WEGAIS/ActChargeOn") .
    sw:insert-attribute ("xmlns:iab", "http://fsrar.ru/WEGAIS/ActInventoryABInfo") . 
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActChargeOn") . 
                sw:start-element ("ain:Header") .
                    sw:write-data-element ("ain:Number", tt-act-header.num) .
                    sw:write-data-element ("ain:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("ain:Note", "Необходимо поставить товарные позиции на баланс") .
                sw:end-element ("ain:Header") .
                sw:start-element ("ain:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next. 
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                    sw:start-element ("ain:Position") .
                        sw:write-data-element ("ain:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("ain:Product") .
                            sw:write-data-element ("pref:Type", "АП") . 
/*                            run gds-attr-value(       */
/*                                tt-gds-act.gds-code,  */
/*                                {&attr-egais-name},   */
/*                                output par-egais-name,*/
/*                                output par-type       */
/*                            ).                        */
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") . 
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) . 
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) . 
                            
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
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
                          v-prod = ''.
                          v-impor = ''.
                          
                          
                          v-prod = entry (1, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if v-prod = ?
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          or v-prod = ""
                          or num-entries (v-prod, chr (5)) < 6 
                          then do:
                            message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.

                          v-impor = entry (2, X_ext-classif-attr.attr-value, chr(4)) no-error.
                          if num-entries (v-impor, chr (5)) > 0 and num-entries (v-impor, chr (5)) < 6 
                            then 
                          do:
                            message "У товара неверно указан импортер из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                          end.                          
                          
                          sw:start-element ("pref:Producer") .
                            if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                            if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                            sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                            sw:start-element ("oref:address").
                              sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                            sw:end-element ("oref:address").
                          sw:end-element ("pref:Producer") .
            
                          if v-impor <> ""
                          and v-impor <> ?
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                          and v-impor <> chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) then do:
                            sw:start-element ("pref:Importer") .
                              if entry (2, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-impor, chr(5)) ).
                              if entry (3, v-impor, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-impor, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-impor, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-impor, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-impor, chr(5)) ).
                              sw:end-element ("oref:address").
                            sw:end-element ("pref:Importer") .
                          end.

                        end.
                        else do:
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        
                        sw:end-element ("ain:Product") .
                        sw:write-data-element ("ain:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("ain:InformAB") .
                            sw:start-element ("ain:InformABReg") . 
                                sw:start-element ("ain:InformA") .
                                    sw:write-data-element ("iab:Quantity", string(tt-gds-act.A-qnty)) no-error .
                                    sw:write-data-element ("iab:BottlingDate", string(iso-date(tt-gds-act.A-bottleDate))) no-error .
                                    sw:write-data-element ("iab:TTNNumber", tt-gds-act.A-ttnNumber) no-error .
                                    sw:write-data-element ("iab:TTNDate", string(iso-date(tt-gds-act.A-ttnDate))) no-error .
                                    if tt-gds-act.A-fixNumber <> ? and trim(tt-gds-act.A-fixNumber) <> "" then do :
                                        sw:write-data-element ("iab:EGAISFixNumber", tt-gds-act.A-fixNumber) no-error .
                                        sw:write-data-element ("iab:EGAISFixDate", string(iso-date(tt-gds-act.A-fixDate))) no-error .
                                    end.
                                sw:end-element ("ain:InformA") .  
                            sw:end-element ("ain:InformABReg") .
                        sw:end-element ("ain:InformAB") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks then do :                
                        sw:start-element ("ain:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("ain:MarkCode", tt-marks.mark) .
            end.    
                        sw:end-element ("ain:MarkCodeInfo") .
        end.         
                    sw:end-element ("ain:Position") .                
    end. 
                sw:end-element ("ain:Content") .
            sw:end-element ("ns:ActChargeOn") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
    
end procedure .

procedure makeXML_v2 :
    create sax-writer sw .
    
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("ns:Documents") .
    sw:insert-attribute ("Version", "1.0") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:oref", "http://fsrar.ru/WEGAIS/ClientRef_v2") .
    sw:insert-attribute ("xmlns:pref", "http://fsrar.ru/WEGAIS/ProductRef_v2") .
    sw:insert-attribute ("xmlns:iab", "http://fsrar.ru/WEGAIS/ActInventoryF1F2Info") .
    sw:insert-attribute ("xmlns:ainp", "http://fsrar.ru/WEGAIS/ActChargeOn_v2") .
    sw:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:ActChargeOn_v2") .
                sw:start-element ("ainp:Header") .
                    sw:write-data-element ("ainp:Number", tt-act-header.num) .
                    sw:write-data-element ("ainp:ActDate", string(iso-date(tt-act-header.date_))) no-error .
                    sw:write-data-element ("ainp:Note", "Необходимо поставить товарные позиции на баланс") .
                    if tt-act-header.type_ <> "Продукция полученная до 01.01.2016"
                    then
                      sw:write-data-element ("ainp:TypeChargeOn", tt-act-header.type_) .
                    else
                      sw:write-data-element ("ainp:TypeChargeOn", "Продукция, полученная до 01.01.2016") .
                    if tt-act-header.type_ = "Пересортица" and v-RegID <> "" and v-RegID <> ? then do :
                      sw:write-data-element ("ainp:ActWriteOff", v-RegID) .  
                    end.
                sw:end-element ("ainp:Header") .
                sw:start-element ("ainp:Content") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
        if tt-gds-act.qnty <= 0 then next. 
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-act.gds-code .
                    sw:start-element ("ainp:Position") .
                        sw:write-data-element ("ainp:Identity", string(tt-gds-act.position_)) .
                        sw:start-element ("ainp:Product") .
                            sw:write-data-element ("pref:UnitType", (if buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1 then "Unpacked" else "Packed")) . 
                            sw:write-data-element ("pref:FullName", tt-gds-act.egais-name) no-error .
                            sw:write-data-element ("pref:ShortName", "") . 
                            sw:write-data-element ("pref:AlcCode", tt-gds-act.alc-code) .
                            if not (buf_goods.unit-base <> buf_goods.unit-cli and buf_goods.cli-base-rate <> 1)
                            then sw:write-data-element ("pref:Capacity", string(buf_goods.ms-base)) . 
                            sw:write-data-element ("pref:AlcVolume", string(buf_goods.proof)) . 
                            
                        for first ub.alc-type-gds where ub.alc-type-gds.gds-code = buf_goods.gds-code no-lock,
                            first ub.alc-type where ub.alc-type.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code no-lock :
                            sw:write-data-element ("pref:ProductVCode", string(ub.alc-type.alc-type-code)) .
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
                          
/*                          v-impor = entry (2, X_ext-classif-attr.attr-value, chr(4)) no-error.                                                                                                                          */
/*                          if (num-entries (v-impor, chr (5)) > 0 and num-entries (v-impor, chr (5)) < 8)                                                                                                                */
/*                              or (trim(v-impor) <> "" and entry (7, v-impor, chr(5)) = "")                                                                                                                              */
/*                            then                                                                                                                                                                                        */
/*                          do:                                                                                                                                                                                           */
/*                            message "У товара неверно указан импортер из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров во второй версии XSD и  заново сохраните акт." view-as alert-box.*/
/*                            v-err-impor = true .                                                                                                                                                                        */
/*                          end.                                                                                                                                                                                          */
                          
                          if not v-err then do :
                            sw:start-element ("pref:Producer") .
                             sw:start-element ("oref:" + entry (7, v-prod, chr(5))) .
                              if entry (7, v-prod, chr(5)) <> "TS" then do :
                                  if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:INN", entry (2, v-prod, chr(5)) ).
                                  if entry (3, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:KPP", entry (3, v-prod, chr(5)) ).
                              end.
                              else if entry (2, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:TSNUM", entry (2, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:ClientRegId", entry (1, v-prod, chr(5)) ).
                              sw:write-data-element ("oref:FullName", entry (4, v-prod, chr(5)) ).
                              sw:start-element ("oref:address").
                                sw:write-data-element ("oref:Country", entry (5, v-prod, chr(5)) ).
                                if entry (8, v-prod, chr(5)) <> "" then sw:write-data-element ("oref:RegionCode", entry (8, v-prod, chr(5)) ).
                                sw:write-data-element ("oref:description", entry (6, v-prod, chr(5)) ).
                              sw:end-element ("oref:address").
                             sw:end-element ("oref:" + entry (7, v-prod, chr(5))) .
                            sw:end-element ("pref:Producer") .
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
                          message "У товара неизвестен производитель из ЕГАИС - " + string (tt-gds-act.gds-code) + ". Выполните синхронизацию товаров и  заново сохраните акт." view-as alert-box.
                        end.
                        
                        sw:end-element ("ainp:Product") .
                        sw:write-data-element ("ainp:Quantity", string(tt-gds-act.qnty)) .
                        sw:start-element ("ainp:InformF1F2") .
                            sw:start-element ("ainp:InformF1F2Reg") . 
                                sw:start-element ("ainp:InformF1") .
                                    sw:write-data-element ("iab:Quantity", string(tt-gds-act.A-qnty)) no-error .
                                    sw:write-data-element ("iab:BottlingDate", string(iso-date(tt-gds-act.A-bottleDate))) no-error .
                                    sw:write-data-element ("iab:TTNNumber", tt-gds-act.A-ttnNumber) no-error .
                                    sw:write-data-element ("iab:TTNDate", string(iso-date(tt-gds-act.A-ttnDate))) no-error .
                                    if tt-gds-act.A-fixNumber <> ? and trim(tt-gds-act.A-fixNumber) <> "" then do :
                                        sw:write-data-element ("iab:EGAISFixNumber", tt-gds-act.A-fixNumber) no-error .
                                        sw:write-data-element ("iab:EGAISFixDate", string(iso-date(tt-gds-act.A-fixDate))) no-error .
                                    end.
                                sw:end-element ("ainp:InformF1") .  
                            sw:end-element ("ainp:InformF1F2Reg") .
                        sw:end-element ("ainp:InformF1F2") .
        find first tt-marks where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ no-lock no-error.
        if available tt-marks then do :                
                        sw:start-element ("ainp:MarkCodeInfo") .
            for each tt-marks no-lock where tt-marks.num = tt-gds-act.num and tt-marks.gds-part-position_ = tt-gds-act.position_ :
                            sw:write-data-element ("MarkCode", tt-marks.mark) .
            end.    
                        sw:end-element ("ainp:MarkCodeInfo") .
        end.         
                    sw:end-element ("ainp:Position") .                
    end. 
                sw:end-element ("ainp:Content") .
            sw:end-element ("ns:ActChargeOn_v2") .
        sw:end-element ("ns:Document") .
    sw:end-element ("ns:Documents") .
    sw:end-document () .
    delete object sw.
    
end procedure .

procedure parseXML :
    empty temp-table tt-act-header .
    empty temp-table tt-gds-act .
    empty temp-table tt-marks .
    
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
   
    hDoc:encoding = 'utf-8'.
    hDoc:LOAD("file", search("temp.xml"),FALSE).
   
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
        IF hNoderef:NAME = "ain:Header" or hNoderef:NAME = "ainp:Header" THEN do :
            create tt-act-header .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value .
        end .
        .
        IF hNoderef:NAME = "ain:Number"
        OR hNoderef:NAME = "ainp:Number" THEN assign tt-act-header.num    = hText:node-value no-error .
        IF hNoderef:NAME = "ain:ActDate"
        OR hNoderef:NAME = "ainp:ActDate" THEN 
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .    
        
        IF hNoderef:NAME = "ainp:TypeChargeOn" THEN do :
            assign tt-act-header.type_    = hText:node-value no-error .
            if tt-act-header.type_ = "Продукция, полученная до 01.01.2016" then tt-act-header.type_ = "Продукция полученная до 01.01.2016" .
        end.
        
        IF hNoderef:NAME = "ainp:ActWriteOff" THEN assign v-RegID    = hText:node-value no-error .
            
        IF hNoderef:NAME = "ain:Position"
        OR hNoderef:NAME = "ainp:Position" THEN do :
            assign ii = 0 .
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "ain:Identity"
        OR hNoderef:NAME = "ainp:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        if hNoderef:NAME = "gds-code" THEN assign tt-gds-act.gds-code = integer(hText:node-value) no-error .
        if hNoderef:NAME = "gds-name" THEN do :
            assign tt-gds-act.gds-name = hText:node-value no-error .
            if tt-gds-act.gds-name = ? or tt-gds-act.gds-name = ""
            then do :
                find first goods no-lock where goods.gds-code = tt-gds-act.gds-code no-error .
                if available goods then tt-gds-act.gds-name = goods.gds-name no-error .
            end.
        end.
        if hNoderef:NAME = "doc-code" THEN assign tt-gds-act.doc-code = hText:node-value no-error .
        if hNoderef:NAME = "part-code" THEN assign tt-gds-act.part-code = hText:node-value no-error .
        IF hNoderef:NAME = "pref:FullName" THEN assign tt-gds-act.egais-name = hText:node-value no-error .   
        IF hNoderef:NAME = "pref:AlcCode" THEN do :
            assign tt-gds-act.alc-code = hText:node-value no-error .
            if tt-gds-act.gds-code = ? or tt-gds-act.gds-code = 0
            then do :
                find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                                   and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                                   AND X_ext-classif.db-num = 0  
                                                   and X_ext-classif.key#_two = v-ext-sys 
                                                   and X_ext-classif.key#_three = 0
                                                   and X_ext-classif.charkey_one = tt-gds-act.alc-code
                                                   and X_eXt-classif.charkey_two = ""
                                                   and X_eXt-classif.charkey_three = ""
                                                   and X_eXt-classif.nonunique = 0
                                                   no-error. 
                if available X_ext-classif then do :
                    find first buf_goods no-lock where buf_goods.gds-code = X_ext-classif.key#_one .
                    assign
                        tt-gds-act.gds-code = buf_goods.gds-code
                        tt-gds-act.gds-name = buf_goods.gds-name
                    .
                    find first X_ext-classif-attr no-lock where X_ext-classif-attr.classif-subject = X_ext-classif.classif-subject
                                                           and X_ext-classif-attr.classif-name = X_ext-classif.classif-name
                                                           and X_ext-classif-attr.db-num = X_ext-classif.db-num
                                                           and X_ext-classif-attr.Key#_One = X_ext-classif.key#_one
                                                           and X_ext-classif-attr.Key#_two = X_ext-classif.key#_two
                                                           and X_ext-classif-attr.Key#_three = X_ext-classif.key#_three
                                                           and X_ext-classif-attr.CharKey_One = X_eXt-classif.charkey_one
                                                           and X_ext-classif-attr.CharKey_two = X_eXt-classif.charkey_two
                                                           and X_ext-classif-attr.CharKey_three = X_eXt-classif.charkey_three
                                                           and X_ext-classif-attr.nonunique = X_eXt-classif.nonunique
                                                           and X_ext-classif-attr.attr-code = 'egais-info'
                                                           no-error .
                    if available X_ext-classif-attr then assign tt-gds-act.egais-name = entry(3, X_ext-classif-attr.attr-value, CHR(4)) no-error.    
                end.
            end.            

        end. 
        IF hNoderef:NAME = "ain:Quantity"
        OR hNoderef:NAME = "ainp:Quantity" THEN assign tt-gds-act.qnty = decimal(hText:node-value) no-error . 
        IF hNoderef:NAME = "iab:Quantity" THEN assign tt-gds-act.A-qnty = decimal(hText:node-value) no-error .
        IF hNoderef:NAME = "iab:BottlingDate" THEN assign tt-gds-act.A-bottleDate = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error . 
        IF hNoderef:NAME = "iab:TTNNumber" THEN assign tt-gds-act.A-ttnNumber = hText:node-value no-error .
        IF hNoderef:NAME = "iab:TTNDate" THEN assign tt-gds-act.A-ttnDate = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        IF hNoderef:NAME = "iab:EGAISFixNumber" THEN assign tt-gds-act.A-fixNumber = hText:node-value no-error . 
        IF hNoderef:NAME = "iab:EGAISFixDate" THEN assign tt-gds-act.A-fixDate = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .
        
        if available tt-gds-act and tt-gds-act.A-ttnNumber <> "" 
        and tt-gds-act.A-ttnNumber <> ? and (tt-gds-act.doc-code = ? or tt-gds-act.doc-code = "")
        then do :
            find first buf_parts no-lock where buf_parts.cst-code = tt-gds-act.A-ttnNumber
                                           and buf_parts.artic = buf_goods.artic
                                            and buf_parts.prod-type = buf_goods.prod-type
                                            and buf_parts.prod-code = buf_goods.prod-code
                                            and buf_parts.obj-type = v-cntxt-obj-type
                                            and buf_parts.obj-code = v-cntxt-obj-code
                                            and buf_parts.out-code = {&free-code}
                                            no-error .
            if available buf_parts then do :
                assign
                    tt-gds-act.part-code = buf_parts.part-code
                    tt-gds-act.doc-code  = buf_parts.in-code    
                .
            end.
            else do :
                find first ub.doc-attr no-lock where ub.doc-attr.attr-code = {&trdcattr-nids} and ub.doc-attr.attr-value = tt-gds-act.A-ttnNumber no-error .
                if available ub.doc-attr then do :
                    assign tt-gds-act.doc-code = ub.doc-attr.doc-code .    
                end.
                else do :
                    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = tt-gds-act.A-ttnNumber no-error .
                    if available buf_trn-doc then do :
                        assign tt-gds-act.doc-code = buf_trn-doc.doc-code .    
                    end.
                end.
            end.    
        end.
            
        IF hNoderef:NAME = "ain:MarkCode"
        OR hNoderef:NAME = "ainp:MarkCode"
        OR hNoderef:NAME = "MarkCode" THEN do :
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

