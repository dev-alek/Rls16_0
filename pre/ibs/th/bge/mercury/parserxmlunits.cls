using Progress.Lang.*.
using ibs.th.bge.mercury.*.
block-level on error undo, throw.
class ibs.th.bge.mercury.ParserXMLUnits:
  define temp-table tt-units-merc
    field guid_ as character format "X(40)"
    field uuid_ as character format "X(40)"
    field name1 as character format "X(5)"
    field name2 as character format "X(20)"
    index pi as primary unique
      guid_
  .
  define variable v-item      as character no-undo .
  define variable v-mess      as character no-undo .
  DEFINE VARIABLE hDoc        AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hRoot       AS HANDLE    NO-UNDO.
  DEFINE VARIABLE good        AS LOGICAL   NO-UNDO.
  define variable v-save-info as character no-undo .
  define variable v-imp       as logical .
  method public void ParseResponse(inFileName as char, INPUT-OUTPUT Table tt-units-merc, output Msg as character):
    empty temp-table tt-units-merc .
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.
    hDoc:LOAD("file",inFileName,FALSE) no-error.
    if inFileName = ? then
    do:
      Msg = "Файл " + inFileName + " не найден" .
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
      IF hNoderef:NAME = "dt:unit" THEN
      DO:
        create tt-units-merc .
      END.
      IF hNoderef:NAME = "bs:uuid" THEN
      DO:
        tt-units-merc.uuid_ = hText:node-value .
      END.
      IF hNoderef:NAME = "bs:guid" THEN
      DO:
        tt-units-merc.guid_ = hText:node-value .
      END.
      IF hNoderef:NAME = "dt:name" THEN
      DO:
        tt-units-merc.name1 = hText:node-value .
      END.
      IF hNoderef:NAME = "dt:fullName" THEN
      DO:
        tt-units-merc.name2 = hText:node-value .
      END.
      GetChildren(hNoderef, (level + 1),msg).
    END.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
  END.
end class.
