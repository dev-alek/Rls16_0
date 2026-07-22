using Progress.Lang.*.
using ibs.th.bge.mercury.*.
block-level on error undo, throw.
class ibs.th.bge.mercury.ParserXMLGds:
define temp-table tt-gds-merq no-undo
  field ID             as integer
  field merc-name      like ub.goods.gds-name label "Полное наименование" format "X(100)"
  field UUID           as character label "UUID"
  field GUID_          as character label "GUID"
  field units          as character label "Ед.измерения"
  field units_th       as character label "Ед.измерения в ТН"
  field status_        as integer   label "Статус"
  field crDate         as date      label "Дата создания" format "99.99.9999"
  field update_Date    as date      label "Дата изменени" format "99.99.9999"
  field prod-type      as integer   label "Тип продукции" format ">>>>9"
  field prod-type-name as character label "Тип продукции"
  field GUID-type      as character label "GUID-type"
  field GUID-subtype   as character label "GUID-subtype"
  index pi as primary
  ID
  index name_ as word-index
  merc-name
  index merq
  GUID_
  .
  define variable v-FS-RAR    as character no-undo .
  define variable v-item      as character no-undo .
  define variable v-mess      as character no-undo .
  DEFINE VARIABLE hDoc        AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hRoot       AS HANDLE    NO-UNDO.
  DEFINE VARIABLE good        AS LOGICAL   NO-UNDO.
  define variable v-save-info as character no-undo .
  define variable v-imp       as logical .
  method public void ParseResponse(inFileName as char, INPUT-OUTPUT Table tt-gds-merq, output Msg as character):
    empty temp-table tt-gds-merq .
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
    hDoc:LOAD("file",inFileName,FALSE) no-error.
    if inFileName = ? then
    do:
      Msg = "Файл не найден" .
      return .
    end.
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    GetChildren(hRoot, 1, output Msg).
    DELETE OBJECT hDoc.
    DELETE OBJECT hRoot.
  end.
  method private void GetChildren(hParent AS HANDLE, level AS INTEGER, output Msg as character):
    DEFINE VARIABLE i        AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE  NO-UNDO.
    DEFINE VARIABLE hText    AS HANDLE  NO-UNDO.
    DEFINE VARIABLE tt       as integer NO-UNDO .
    tt = hParent:NUM-CHILDREN no-error .
    if tt = ? then
    do:
      Msg = "Ошибка запроса. См. в файле ответа" .
      return.
    end.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT i = 1 TO hParent:NUM-CHILDREN:
      good = hParent:GET-CHILD(hNoderef,i).
      IF NOT good THEN
        LEAVE.
      IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
      hNoderef:GET-CHILD(hText, 1) no-error .
      IF hNoderef:NAME = "dt:productItem" THEN
      DO:
        v-item = "ProductItem" .
        create tt-gds-merq .
      END.
      IF hNoderef:NAME = "dt:product" THEN
      DO:
        v-item = "Product" .
      END.
      IF hNoderef:NAME = "dt:subProduct" THEN
      DO:
        v-item = "SubProduct" .
      END.
      IF hNoderef:NAME = "dt:unit" THEN
      DO:
        v-item = "Unit" .
      END.
      IF hNoderef:NAME = "bs:uuid" and v-item = "Product"    THEN assign tt-gds-merq.UUID = hText:node-value .
      if v-item = "ProductItem" then
      do:
        IF hNoderef:NAME = "bs:guid"    THEN assign tt-gds-merq.GUID_ = hText:node-value .
        IF hNoderef:NAME = "bs:createDate"    THEN assign tt-gds-merq.crDate = date(DateMercury(hText:node-value)) .
        IF hNoderef:NAME = "bs:updateDate"    THEN assign tt-gds-merq.update_Date = date(DateMercury(hText:node-value)) .
        IF hNoderef:NAME = "dt:name"          THEN assign tt-gds-merq.merc-name = hText:node-value .
      end.
      if v-item = "Product" then
      do:
        IF hNoderef:NAME = "bs:guid"    THEN assign tt-gds-merq.GUID-type = hText:node-value .
      end.
      if v-item = "SubProduct" then
      do:
        IF hNoderef:NAME = "bs:guid"    THEN assign tt-gds-merq.GUID-subtype = hText:node-value .
      end.
      if v-item = "unit" then
      do:
        IF hNoderef:NAME = "dt:name"          THEN assign tt-gds-merq.units = hText:node-value .
      end.
      IF hNoderef:NAME = "dt:productType"   THEN assign tt-gds-merq.prod-type = INTEGER (hText:node-value) .
      IF hNoderef:NAME = "dt:status"    THEN assign tt-gds-merq.status_ = INTEGER(hText:node-value) .
      if hNoderef:NAME begins "base:error" then do: assign Msg = hText:NODE-VALUE .
      return.
      end.
      GetChildren(hNoderef, (level + 1),msg).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
  END.
  method private character DateMercury (inValue as character):
    def var v-str as character no-undo.
    inValue = entry (1,inValue,"T")  .
    if inValue = "0001-01-01" then v-str = ? .
    else v-str = entry (3, string(inValue), "-") + "/" + entry (2, string(inValue), "-") + "/" + entry (1, string(inValue), "-") .
    return v-str.
  end.
end class.
