
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
/*    field type_         as character        label "Основание списания" format "X(18)"*/
    field is-sent       as logical
    index pi as primary unique
        num
.

define temp-table tt-gds-act
    field num           as character                label "№ акта"
    field position_     as integer                  label "№ пп"                    format ">>>9"
    field type_         as character                label "Тип"         format "X(3)"
    field rank          as character                label "Серия"     format "X(3)" 
    field number        as character                label "Номер"               format "X(9)"
    field mark          as character                label "Марка"   format "X(100)" 
    index pi as primary unique
        position_
.

&if "{1}" = "proc" &then

define variable sw as handle no-undo .

define variable v-file              as character no-undo initial "QueryBarcode1.xml".

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
    sw:insert-attribute ("xmlns:ns", "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:bk", "http://fsrar.ru/WEGAIS/QueryBarcode") .
    sw:insert-attribute ("xmlns:ce", "http://fsrar.ru/WEGAIS/CommonEnum") .
        sw:start-element ("ns:Owner") . 
            sw:write-data-element ("ns:FSRAR_ID", v-fs-rar) .
        sw:end-element ("ns:Owner") . 
        sw:start-element ("ns:Document") .
            sw:start-element ("ns:QueryBarcode") .
                sw:write-data-element ("bk:QueryNumber", tt-act-header.num) no-error .
                sw:write-data-element ("bk:Date", string(iso-date(tt-act-header.date_)) + "T12:00:00") no-error .
                sw:start-element ("bk:Marks") .
    for each tt-gds-act no-lock where tt-gds-act.num = tt-act-header.num :
                    sw:start-element ("bk:Mark") .
                        sw:write-data-element ("bk:Identity", string(tt-gds-act.position_)) no-error .
                        sw:write-data-element ("bk:Type", tt-gds-act.type_) no-error .
                        sw:write-data-element ("bk:Rank", tt-gds-act.rank) no-error .
                        sw:write-data-element ("bk:Number", tt-gds-act.number) no-error .
                        if tt-gds-act.mark <> ? and tt-gds-act.mark <> ""
                        then sw:write-data-element ("bk:Barcode", tt-gds-act.mark) no-error .
                    sw:end-element ("bk:Mark") .                
    end. 
                sw:end-element ("bk:Marks") .
            sw:end-element ("ns:QueryBarcode") .
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
        IF hNoderef:NAME = "bk:QueryNumber" THEN do :
            create tt-act-header .
            assign tt-act-header.num = hText:node-value no-error .
            assign tt-act-header.is-sent = bh-act-header:buffer-field("is-sent"):buffer-value no-error.
        end .
        .
        IF hNoderef:NAME = "bk:Date" THEN 
            assign tt-act-header.date_ = date(substring(hText:node-value, 9, 2) + "/" + substring(hText:node-value, 6, 2) + "/" + substring(hText:node-value, 1, 4)) no-error .    
        IF hNoderef:NAME = "bk:Mark" THEN do :
            create tt-gds-act .
            assign tt-gds-act.num = tt-act-header.num .
        end.
        IF hNoderef:NAME = "bk:Identity" THEN assign tt-gds-act.position_ = integer(hText:node-value) no-error .
        IF hNoderef:NAME = "bk:Type" THEN assign tt-gds-act.type_ = hText:node-value no-error . 
        IF hNoderef:NAME = "bk:Rank" THEN assign tt-gds-act.rank = hText:node-value no-error .
        IF hNoderef:NAME = "bk:Number" THEN assign tt-gds-act.number = hText:node-value no-error .
        IF hNoderef:NAME = "bk:Barcode" THEN assign tt-gds-act.mark = hText:node-value no-error .
             
        run GetChildren (hNoderef, (level + 1)).
        
    END.
    
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
END procedure.
&endif
