using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.export.expsubject:
  define property Data as memptr no-undo
    get.
    private set.
  define property Msg as character no-undo
    get.
    private set.
  define property InitSecTag as character no-undo
    get.
    private set.
   define property sendTableName  as character  no-undo
     get.
     private set.
   define property sendOldRowid as rowid  no-undo
     get.
     private set.
   define property sendNewRowid as rowid  no-undo
     get.
     private set.
  method public void GetContent (expsubject as class ibs.th.bge.1crn.subjects.iexpsubject, inType as char, inFileName as char):
    define variable sw as handle no-undo.
    create sax-writer sw.
    sw:formatted = true.
    case inType:
      when "memptr"
        then sw:set-output-destination ("memptr", Data).
      when "file"
        then sw:set-output-destination ("file", inFileName).
    end.
    sw:encoding = "UTF-8".
    sw:fragment = true .
    sw:start-document () .
    expsubject:CrContentToSW (sw).
    InitSecTag = expsubject:InitSecTag.
    sendTableName = expsubject:sendTableName.
    sendOldRowid  = expsubject:sendOldRowid.
    sendNewRowid  = expsubject:sendNewRowid.
    if inType = "memptr" and get-size(Data) > 0 and sendTableName = "" or
      (sendTableName <> "code" and sendTableName <> "Cash-param-hist" and sendOldRowid = ? and sendNewRowid = ?) then
    do:
      Msg = substitute(
        "ƒолжны быть установлены об€зательные свойства класса экспорта: охватывающий тег, таблица и rowid выгружаемой записи (&1).",
        expsubject:InitSecTag
      ).
      return error.
    end.
    sw:end-document () .
   end.
   method public void GetContent (expsubject as class ibs.th.bge.1crn.subjects.iexpsubject):
     GetContent (expsubject, "memptr", ?).
   end.
end class.
