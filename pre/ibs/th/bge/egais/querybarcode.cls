using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.QueryBarcode inherits EGAISUTM:
define temp-table tt-act-header
    field num           as character        label "№ акта"      format "X(30)"
    field date_         as date             label "Дата акта"
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define stream outstr.
  define private buffer buf_clob-bind for ub.clob-bind.
  define private buffer buf_clob-data for ub.clob-data.
  define private variable parameters     as character no-undo.
  define private variable inFileName     as character no-undo.
  define private variable inData         as character no-undo.
  define private variable outData        as character no-undo.
  define private variable cmd            as character no-undo.
  define private variable urlResp        as character no-undo.
  define private variable v-uniq-key-rec as character no-undo.
  define private variable v-Answer       as character no-undo.
  define private variable v-RegID        as character no-undo.
  define private variable ticket2        as logical   no-undo.
  define variable v-FS-RAR  as character no-undo .
  define variable ObjType   as character no-undo .
  define variable ObjCode   as integer   no-undo .
  define variable Obj       as character no-undo .
  define variable v-ext-sys as integer   no-undo .
  DEFINE VARIABLE good AS LOGICAL NO-UNDO.
  define property inNum as character no-undo
    get.
    set.
  constructor public QueryBarcode (inOjType as char, inObjCode as int, inFSRAR as char, inExtSys as integer):
    super (inOjType, inObjCode).
    ObjCode = inObjCode.
    ObjType = inOjType.
    Obj = "*" + substring(ObjType,1,1) + string(ObjCode) + "*" .
    v-FS-RAR = inFSRAR.
    v-ext-sys = inExtSys.
    IsSent.
  end constructor.
  method public override handle GetHndlTable(inTableType as int, inAbIndenty as char) :
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable ii    as integer no-undo.
    assign
      parameters = inNum
      StatusErr = false
      Msg       = ""
      .
    case inTableType:
      when 3 then
        do:
          empty temp-table tt-act-header.
          for each buf_clob-bind where buf_clob-bind.field-name_ = 'egais-qb':U:
            if entry(1, buf_clob-bind.descr, chr(4)) matches Obj
            then .
            else next .
            create tt-act-header.
            assign
                tt-act-header.num       = (entry (1, buf_clob-bind.descr, chr(4)))
                tt-act-header.date_     = date (entry (2, buf_clob-bind.descr, chr(4)))
                tt-act-header.is-sent   = logical (entry (3, buf_clob-bind.descr, chr(4)))
            .
            end.
          return buffer tt-act-header:handle.
        end.
      when 2 then
      do :
                v-Answer = "" .
        v-RegID = "" .
        create x-document hDoc.
        create x-noderef  hRoot.
        IsSent.
        if ConPar = "" or ConPar = ?
        then do:
          StatusErr = true.
          Msg = "Не заданы настройки соединения для EGAIS".
          return ?.
        end.
        GetSubjectOfRequestUTM().
        if StatusErr
          then return ?.
        file-info:file-name = search (inFileName).
        if search (inFileName) = ? or file-info:file-size = 0
        then do:
          assign
            StatusErr = true
            Msg = "Не удалось получить данные от UTM"
          .
          return ?.
        end.
        if not WriteDbStatus ( 4, parameters , ReplyId, true )
        then do:
          assign
            StatusErr = true
            Msg = "Не удалось записать данные о запросе в БД. Запрос не выполен."
          .
          undo, return ?.
        end.
      end.
    end case.
  end.
  method override public logical SendRequestUTM ():
    def var ii        as int    no-undo.
    def var xml-cont  as char   no-undo.
    def var respValue as handle no-undo.
    assign
      parameters = inNum
      StatusErr = false
      Msg       = ""
      .
    isSent.
    do trans:
      os-delete "RespQueryBarcode.xml".
      assign
        inFileName = "RespQueryBarcode.xml"
        .
      find first tt-act-header no-error.
      if available (tt-act-header)
        then
      do:
          cmd = substitute ("&1 --connect-timeout &5 -F xml_file=@&2 &3/opt/in/QueryBarcode >&4", search ("exe/curl.exe"), search ("QueryBarcode.xml"), ConPar, inFileName, TimeOut).
          os-command silent value (cmd).
          file-info:file-name = search (inFileName).
          if search (inFileName) <> ? and file-info:file-size > 0
            then
          do:
            respValue = ParseRequest (inFileName).
            if respValue = ?
              then
            do:
              assign
                StatusErr = true
                Msg       = "Не удалось разобрать данные от UTM"
                .
              undo, return false.
            end.
            if not StatusErr
              then
              ReplyId = respValue:node-value.
            else
            do:
              assign
                StatusErr = true
                Msg       = respValue:node-value
                .
              undo, return false.
            end.
          end.
          else
          do:
            assign
              StatusErr = true
              Msg       = "Не удалось отправить запрос в UTM"
              .
            undo, return false.
          end.
          if not WriteDbStatus (4, parameters , ReplyId, false)
          then do:
            assign
              StatusErr = true
              Msg = "Не удалось записать данные о запросе в БД. Запрос не выполен."
            .
            undo, return false.
          end.
      end.
    end.
  end.
  method override protected logical GetIsSent ():
    find first ub.esys-all-attr
                where ub.esys-all-attr.table-name = "esys-pck-sent"
                and ub.esys-all-attr.attr-code = "egais"
                and ub.esys-all-attr.key2       = 4
                and ub.esys-all-attr.attr-value = parameters
                no-error.
    if available (ub.esys-all-attr )
    then do:
      ReplyId = ub.esys-all-attr.key7.
      return true.
    end.
    return false.
  end.
  method protected handle ParseRequest (inFileName as char):
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable hRow  as handle  no-undo.
    define variable hText as handle  no-undo.
    define variable ii    as integer no-undo.
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef htext .
    hDoc:load ("file", inFileName, false).
    hDoc:encoding = "UTF-8".
    hDoc:get-document-element(hRoot) .
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            hRow:get-child (hText, 1) no-error.
            return hText.
          end.
        when "error" then
          do:
            hRow:get-child (hText, 1) no-error.
            StatusErr = true.
            return hText.
          end.
        otherwise
          do:
            return ?.
          end.
      end case.
    end.
  end.
  method private void GetChildren(hParent AS HANDLE, level AS INTEGER):
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
        DEFINE VARIABLE hText AS HANDLE NO-UNDO.
        define variable v-ok as logical no-undo .
        CREATE X-NODEREF hNoderef.
        CREATE X-NODEREF hText .
        REPEAT i = 1 TO hParent:NUM-CHILDREN:
            good = hParent:GET-CHILD(hNoderef,i).
            IF NOT good THEN
                LEAVE.
            IF hNoderef:SUBTYPE <> "element" THEN
                NEXT.
            hNoderef:GET-CHILD(hText, 1) no-error .
            IF hNoderef:NAME = "tc:RegID"    THEN v-RegID  = hText:node-value .
            IF hNoderef:NAME = "tc:Conclusion"
            OR hNoderef:NAME = "tc:OperationResult" THEN
            DO :
                if hText:node-value = "Rejected" then v-RegID = v-RegID + CHR(5) + "R" .
                if hText:node-value = "Accepted" then v-RegID = v-RegID + CHR(5) + "A" .
            END.
            IF hNoderef:NAME = "tc:Comments" THEN do :
                if trim(v-Answer) = '' or v-Answer = chr(10) then v-Answer = hText:node-value .
                else v-Answer = v-Answer + chr(10) + hText:node-value .
            end.
            IF hNoderef:NAME = "tc:OperationResult" THEN v-ok = (hText:node-value = "Accepted") .
            IF hNoderef:NAME = "tc:OperationComment" THEN v-Answer = v-Answer + chr(10) + hText:node-value .
            GetChildren(hNoderef, (level + 1)).
        END.
        DELETE OBJECT hNoderef.
        DELETE OBJECT hText.
  END.
  method public override character GetSubjectOfRequestUTM() :
    define variable response as character no-undo .
    urlResp = GetURLUTM(ReplyId).
    if StatusErr and Msg <> "" and Msg <> ? then return ? .
    if urlResp = "" or urlResp = ?
    then do:
      StatusErr = true.
      Msg = "Еще не получен ответ от сервера EGAIS по запросу " + ReplyId.
      return ?.
    end.
    os-delete "RespQueryBarcode.xml".
    assign
      inFileName = "RespQueryBarcode.xml"
      response = urlResp
    .
    if trim(response) <> "" then do :
        cmd = substitute ("&1 --connect-timeout &2 -X GET &3 >&4", search ("exe/curl.exe"), TimeOut, response, inFileName).
        os-command silent value (cmd).
    end.
  end.
  method protected override character GetURLUTM (inReplyId as char):
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable hRow  as handle  no-undo.
    define variable hText as handle  no-undo.
    define variable ii    as integer no-undo.
    define variable files as character no-undo.
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef  hText.
    assign
      inFileName = "ReceiptListOfQuery.xml"
    .
    if search ("ReceiptListOfQuery.xml") <> ? then os-delete value (inFileName).
    if search (inFileName) <> ? then os-delete value (inFileName).
    cmd = substitute ("&1 --connect-timeout &2 -X GET &3/opt/out?refresh=true >&4",search ("exe/curl.exe"), TimeOut, ConPar, inFileName).
    os-command silent value (cmd).
    file-info:file-name = search (inFileName).
    if search (inFileName) = ? or file-info:file-size = 0
    then do:
      assign
        StatusErr = true
        Msg = "Не удалось получить данные от UTM"
      .
      return ?.
    end.
    hDoc:load ("file", inFileName, false).
    hDoc:get-document-element(hRoot) .
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            if hRow:get-attribute("replyId") = ReplyId
            then do:
              hRow:get-child (hText, 1) no-error.
              files = files + chr(4) + hText:node-value.
            end.
          end.
      end case.
    end.
    files = trim(files, chr(4)) .
    return files .
  end.
end class.
