using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ParserXMLRests inherits EGAISUTM:
    define variable v-FS-RAR as character no-undo .
    define property v-date-time as character no-undo
        get.
        set.
    define temp-table tt-gds-rests-EG no-undo
    field gds-code          like ub.goods.gds-code          label "Код товара в TH"
    field gds-name          like ub.goods.gds-name          label "Наименование товара" format "X(100)"
    field alc-code          as character                    label "Алкогольный код"     format "X(21)"
    field ms-base           like ub.goods.ms-base           label "Объем"               format ">>9.9<<"
    field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
    field proof             like ub.goods.proof             label "Крепость"            format ">9.9"
    field fromEgais         as logical
    field egais-name        as character                    label "Наименование ЕГАИС"  format "X(100)"
    field egais-qnty        as decimal                      label "Остаток ЕГАИС"
    field informA_          as character                    label "ID справки А"        format "X(30)"
    field informB_          as character                    label "ID справки Б"        format "X(30)"
    field TH-qnty           as decimal                      label "Остаток TH"
    field packed            as logical
    index pi as primary
        gds-code
    index name_ as word-index
        gds-name
    index alc
        alc-code
    .
    DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
    DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
    DEFINE VARIABLE good AS LOGICAL NO-UNDO.
    constructor public ParserXMLRests (inOjType as char, inObjCode as int):
      super (inOjType, inObjCode).
    end constructor.
    method override handle ParseResponse(inFileName as char):
        empty temp-table tt-gds-rests-EG .
        CREATE X-DOCUMENT hDoc.
        CREATE X-NODEREF hRoot.
        hDoc:LOAD("file",inFileName,FALSE).
        hDoc:GET-DOCUMENT-ELEMENT(hRoot).
        GetChildren(hRoot, 1).
        DELETE OBJECT hDoc.
        DELETE OBJECT hRoot.
        return buffer tt-gds-rests-EG:handle.
    end.
    method private void GetChildren(hParent AS HANDLE, level AS INTEGER):
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
            IF hNoderef:NAME = "ns:FSRAR_ID" THEN
                assign v-FS-RAR = hText:node-value .
            IF hNoderef:NAME = "rst:StockPosition" THEN
                create tt-gds-rests-EG .
            IF hNoderef:NAME = "rst:RestsDate"   THEN assign v-date-time        = hText:node-value .
            IF hNoderef:NAME = "rst:Quantity"    THEN assign tt-gds-rests-EG.egais-qnty        = decimal(hText:node-value) .
            IF hNoderef:NAME = "rst:InformARegId"
            OR hNoderef:NAME = "rst:InformF1RegId" THEN assign tt-gds-rests-EG.informA_          = hText:node-value .
            IF hNoderef:NAME = "rst:InformBRegId"
            OR hNoderef:NAME = "rst:InformF2RegId" THEN assign tt-gds-rests-EG.informB_          = hText:node-value .
            IF hNoderef:NAME = "pref:FullName"     THEN do :
                if trim(tt-gds-rests-EG.gds-name) = "" then assign tt-gds-rests-EG.gds-name        = hText:node-value .
            end.
            IF hNoderef:NAME = "pref:AlcCode"      THEN assign tt-gds-rests-EG.alc-code        = hText:node-value .
            IF hNoderef:NAME = "pref:UnitType"     THEN assign tt-gds-rests-EG.packed          = (hText:node-value = "Packed") .
            IF hNoderef:NAME = "pref:Capacity"     THEN assign tt-gds-rests-EG.ms-base         = decimal(hText:node-value) .
            IF hNoderef:NAME = "pref:AlcVolume"    THEN assign tt-gds-rests-EG.proof           = decimal(hText:node-value) .
            IF hNoderef:NAME = "pref:ProductVCode" THEN assign tt-gds-rests-EG.alc-type-code   = hText:node-value .
            GetChildren(hNoderef, (level + 1)).
        END.
        DELETE OBJECT hNoderef.
        DELETE OBJECT hText.
    END.
end class.
