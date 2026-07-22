using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ParserXMLDictOrg inherits EGAISUTM:
    define variable v-FS-RAR as character no-undo .
    define temp-table tt-objs-EG no-undo
        field obj-type          like ub.clients.obj-type
        field obj-code          like ub.clients.obj-code
        field obj-name-th       as character label "Наименование в TH"
        field obj-name-egais    as character label "Наименование ЕГАИС"    format "X(100)"
        field regID             as character label "Регистрационный номер" format "X(21)"
        field inn               as character label "ИНН"
        field kpp               as character label "КПП"
        field country           as character label "Код страны"
        field regionCode        as character label "Код региона"
        field district          as character label "Район"
        field city              as character label "Город"
        field settlement        as character label "Населенный пункт"
        field street            as character label "Улица"
        field house-number      as character label "Номер дома"
        field house-case        as character label "Корпус"
        field house-apartment   as character label "Номер квартиры"
        field house-litera      as character label "Литера"
        field postIndex         as character label "Почтовый индекс"
        field description_      as character label "Адрес"                  format "X(100)"
        field fromEgais         as logical
        field connected_        as logical
        field obj-name-egais-short as character label "Короткое наименование ЕГАИС" format "X(100)"
        field versionWB         as character format "X(10)"
        field typeEgais         as character format "X(2)"
        index pi
            inn kpp
    .
    DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
    DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
    DEFINE VARIABLE good AS LOGICAL NO-UNDO.
    constructor public ParserXMLDictOrg (inOjType as char, inObjCode as int):
      super (inOjType, inObjCode).
    end constructor.
    method override handle ParseResponse(inFileName as char):
        empty temp-table tt-objs-EG .
        CREATE X-DOCUMENT hDoc.
        CREATE X-NODEREF hRoot.
        hDoc:LOAD("file",inFileName,FALSE).
        hDoc:GET-DOCUMENT-ELEMENT(hRoot).
        GetChildren(hRoot, 1).
        DELETE OBJECT hDoc.
        DELETE OBJECT hRoot.
        return buffer tt-objs-EG:handle.
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
            IF hNoderef:NAME = "rc:Client" THEN do :
                create tt-objs-EG .
                assign tt-objs-EG.fromEgais = yes .
            end.
            IF hNoderef:NAME = "oref:UL"
            OR hNoderef:NAME = "oref:FL"
            OR hNoderef:NAME = "oref:FO"
            OR hNoderef:NAME = "oref:TS"
            THEN assign tt-objs-EG.typeEgais = entry(2, hNoderef:NAME, ":") .
            IF hNoderef:NAME = "oref:ClientRegId" THEN assign tt-objs-EG.regID          = hText:node-value .
            IF hNoderef:NAME = "oref:INN"         THEN assign tt-objs-EG.inn            = hText:node-value .
            IF hNoderef:NAME = "oref:KPP"         THEN assign tt-objs-EG.kpp            = hText:node-value .
            IF hNoderef:NAME = "oref:FullName"    THEN assign tt-objs-EG.obj-name-egais = hText:node-value .
            IF hNoderef:NAME = "oref:ShortName"   THEN assign tt-objs-EG.obj-name-egais-short = hText:node-value .
            IF hNoderef:NAME = "oref:Country"     THEN assign tt-objs-EG.country        = hText:node-value .
            IF hNoderef:NAME = "oref:Index"       THEN assign tt-objs-EG.postIndex      = hText:node-value .
            IF hNoderef:NAME = "oref:RegionCode"  THEN assign tt-objs-EG.regionCode     = hText:node-value .
            IF hNoderef:NAME = "oref:area"        THEN assign tt-objs-EG.district       = hText:node-value .
            IF hNoderef:NAME = "oref:city"        THEN assign tt-objs-EG.city           = hText:node-value .
            IF hNoderef:NAME = "oref:place"       THEN assign tt-objs-EG.settlement     = hText:node-value .
            IF hNoderef:NAME = "oref:street"      THEN assign tt-objs-EG.street         = hText:node-value .
            IF hNoderef:NAME = "oref:house"       THEN assign tt-objs-EG.house-number   = hText:node-value .
            IF hNoderef:NAME = "oref:building"    THEN assign tt-objs-EG.house-case     = hText:node-value .
            IF hNoderef:NAME = "oref:liter"       THEN assign tt-objs-EG.house-litera   = hText:node-value .
            IF hNoderef:NAME = "oref:description" THEN assign tt-objs-EG.description_   = hText:node-value .
            IF hNoderef:NAME = "oref:VersionWB"   THEN assign tt-objs-EG.versionWB      = hText:node-value .
            GetChildren(hNoderef, (level + 1)).
        END.
        DELETE OBJECT hNoderef.
        DELETE OBJECT hText.
    END.
end class.
