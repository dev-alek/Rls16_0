using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ParserXMLDictGds inherits EGAISUTM:
    define variable v-FS-RAR as character no-undo .
    define temp-table tt-gds-EG no-undo
        field gds-code          like ub.goods.gds-code          label "Код товара в TH"
        field gds-name          like ub.goods.gds-name          label "Полное наименование" format "X(120)"
        field alc-code          as character                    label "Алкогольный код"     format "X(30)"
        field ms-base           like ub.goods.ms-base           label "Объем"               format ">>9.9<<"
        field alc-type-code     like ub.alc-type.alc-type-code  label "Код АП"
        field proof             like ub.goods.proof             label "Крепость"            format ">9.9"
        field prod-info         as character
        field imp-info          as character
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
    define variable v-save-info as character no-undo .
    define variable v-imp as logical .
    constructor public ParserXMLDictGds (inOjType as char, inObjCode as int):
      super (inOjType, inObjCode).
    end constructor.
    method override handle ParseResponse(inFileName as char):
        empty temp-table tt-gds-EG .
        CREATE X-DOCUMENT hDoc.
        CREATE X-NODEREF hRoot.
        hDoc:LOAD("file",inFileName,FALSE).
        hDoc:GET-DOCUMENT-ELEMENT(hRoot).
        GetChildren(hRoot, 1).
        DELETE OBJECT hDoc.
        DELETE OBJECT hRoot.
        return buffer tt-gds-EG:handle.
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
            IF hNoderef:NAME = "rap:Product" THEN DO:
                create tt-gds-EG .
                assign
                  tt-gds-EG.imp-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                  tt-gds-EG.prod-info = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5)
                .
             END.
            IF hNoderef:NAME = "pref:ShortName"    THEN assign tt-gds-EG.gds-name        = hText:node-value .
            IF hNoderef:NAME = "pref:FullName"     THEN do :
                if trim(tt-gds-EG.gds-name) = "" then assign tt-gds-EG.gds-name        = hText:node-value .
            end.
            IF hNoderef:NAME = "pref:AlcCode"      THEN assign tt-gds-EG.alc-code        = hText:node-value .
            IF hNoderef:NAME = "pref:Capacity"     THEN assign tt-gds-EG.ms-base         = decimal(hText:node-value) .
            IF hNoderef:NAME = "pref:AlcVolume"    THEN assign tt-gds-EG.proof           = decimal(hText:node-value) .
            IF hNoderef:NAME = "pref:ProductVCode" THEN assign tt-gds-EG.alc-type-code   = hText:node-value .
            IF hNoderef:NAME = "pref:Producer"     THEN assign v-imp       = false .
            IF hNoderef:NAME = "pref:Importer"     THEN assign v-imp       = true .
            IF hNoderef:NAME = "oref:UL"
            OR hNoderef:NAME = "oref:FL"
            OR hNoderef:NAME = "oref:FO"
            OR hNoderef:NAME = "oref:TS"
            THEN DO :
                if v-imp then assign entry (7, tt-gds-EG.imp-info, chr(5)) = entry(2, hNoderef:NAME, ":") .
                else          assign entry (7, tt-gds-EG.prod-info, chr(5)) = entry(2, hNoderef:NAME, ":") .
            END.
            IF hNoderef:NAME = "oref:ClientRegId" THEN DO :
                if v-imp then assign entry (1, tt-gds-EG.imp-info, chr(5)) = hText:node-value .
                else          assign entry (1, tt-gds-EG.prod-info, chr(5)) = hText:node-value .
            end.
            IF hNoderef:NAME = "oref:INN"
            OR hNoderef:NAME = "oref:TSNUM"       THEN do :
                if v-imp then assign entry (2, tt-gds-EG.imp-info, chr(5)) = hText:node-value .
                else          assign entry (2, tt-gds-EG.prod-info, chr(5)) = hText:node-value .
            end.
            IF hNoderef:NAME = "oref:KPP"         THEN do :
                if v-imp then assign entry (3, tt-gds-EG.imp-info, chr(5)) = hText:node-value .
                else          assign entry (3, tt-gds-EG.prod-info, chr(5)) = hText:node-value .
            end.
            IF hNoderef:NAME = "oref:FullName"    THEN do :
                if v-imp then assign entry (4, tt-gds-EG.imp-info, chr(5)) = hText:node-value .
                else          assign entry (4, tt-gds-EG.prod-info, chr(5)) = hText:node-value .
            end.
            IF hNoderef:NAME = "oref:Country"     THEN do :
                if v-imp then assign entry (5, tt-gds-EG.imp-info, chr(5)) = hText:node-value .
                else          assign entry (5, tt-gds-EG.prod-info, chr(5)) = hText:node-value .
            end.
            IF hNoderef:NAME = "oref:RegionCode"  THEN do :
                if v-imp then assign entry (8, tt-gds-EG.imp-info, chr(5)) = hText:node-value .
                else          assign entry (8, tt-gds-EG.prod-info, chr(5)) = hText:node-value .
            end.
            IF hNoderef:NAME = "oref:description" THEN do :
                if v-imp then do :
                    v-save-info = tt-gds-EG.imp-info .
                    assign entry (6, tt-gds-EG.imp-info, chr(5)) = hText:node-value no-error .
                    if tt-gds-EG.imp-info = ? then tt-gds-EG.imp-info = v-save-info .
                end.
                else do :
                    v-save-info = tt-gds-EG.prod-info .
                    assign entry (6, tt-gds-EG.prod-info, chr(5)) = hText:node-value no-error .
                    if tt-gds-EG.prod-info = ? then tt-gds-EG.prod-info = v-save-info .
                end.
            end.
            GetChildren(hNoderef, (level + 1)).
        END.
        DELETE OBJECT hNoderef.
        DELETE OBJECT hText.
    END.
end class.
