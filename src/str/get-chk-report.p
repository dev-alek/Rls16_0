block-level on error undo, throw.
/*
$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Обмен данными с кассой по кассовым отчетам

*/

define input  parameter parparentproc   as widget-handle         no-undo.
define input  parameter p-parent-handle as widget-handle         no-undo.
define input  parameter p-log-handle    as handle                no-undo.
define input  parameter p-log-file-name as character             no-undo.
define input  parameter p-obj-type      like ub.clients.obj-type no-undo.
define input  parameter p-obj-code      like ub.clients.obj-code no-undo.
define output parameter p-ok            as logical               no-undo.

define variable vss-revision    as character no-undo init "$Revision: 75e9ec6019c5, 3128, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Чт сен 15 14:05:53 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-chk-Report.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-chk-Report.p $":U .
define variable vss-description as character no-undo init "Обмен данными с кассой по кассовым отчетам".

{ cmp/str-glbl.i }
{ gbl/cd-attr.i }
{ str/get-chk.i }
{ ref/gdsoattr.i }
{ cmp/ini-lib.i  }
{ bge/socet.i }
define variable Mreq as longchar no-undo.
define variable m-time          as character no-undo.
/*{ gbl/getcntxt.i def }*/
/*{ gbl/getcntxt.i get }*/

function fConvetDate returns datetime
    (input iTStamp as character):
   
    define variable vDateTime as datetime no-undo.
    define variable vDate     as date     no-undo.
    define variable vDays     as int64    no-undo.
    define variable vSec      as integer  no-undo.

    vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
    vDate = date("01/01/1970") + vDays.
   
    return vDate.
end function.

function fConvetDateTime returns datetime
    (input iTStamp as character):
   
    define variable vDateTime as datetime no-undo.
    define variable vDate     as date     no-undo.
    define variable vDays     as int64    no-undo.
    define variable vSec      as integer  no-undo.

    vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
    vDate = date("01/01/1970") + vDays.
    vSec = (int64(iTStamp) - vDays * 3600 * 24).
    vDateTime = datetime(string(vDate) + " " + string(vSec, "HH:MM:SS")).
   
    return vDateTime.
end function.

define temp-table tt-chk-report-head no-undo like chk-slip-head .
define temp-table tt-one-chk-report-head no-undo like chk-slip-head .
define temp-table tt-chk-report-string no-undo like chk-slip-string .

define variable v-tth                as handle    no-undo.
define variable v-Param-Type         as character no-undo.
define variable out                  as character no-undo.
define variable in_                  as character no-undo.
define variable glog                 as logical   no-undo.
define variable v-value-character    as character no-undo.
define variable v-value-date         as date      no-undo.
define variable v-value-decimal      as decimal   no-undo.
define variable v-value-integer      as integer   no-undo.
define variable v-value-logical      as logical   no-undo.
define variable v-no-get-chk         as logical   no-undo.

define variable m-obj-code           as integer   no-undo.
define variable m-cash-num           as integer   no-undo.
define variable m-pos-type           as character no-undo.
define variable m-post-file-name     as character no-undo.
define variable m-response-file-name as character no-undo.
define variable m-xml-file-name      as character no-undo.
define variable m-obj-list           as character no-undo.
define variable m-correspondent      as character no-undo.
define variable m-timestamp          as character no-undo.
define variable Check-ctrl           as character no-undo.
define variable ErrorMessage         as character no-undo.
define variable mElement             as character no-undo.
define variable mCount               as int64     no-undo.
define variable m-err-msg            as character no-undo.
define variable m-textCheq           as longchar  no-undo.
define variable m-ParamJson          as longchar  no-undo.


run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-get-chk}
    ,input  {&attr-get-chk_no-get-chk} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

v-no-get-chk = v-value-logical.
if v-no-get-chk then 
do:
    m-err-msg = substitute( "Согласно настроечным параметрам НЕТ приема отчетов в &1&2!!!&3"
        ,p-obj-type
        ,p-obj-code
        ,{&new-line}
        ).
    return error m-err-msg.
end.

run verify-ini-entry("in":U,
    substitute("kassa-&1":U, {&cd-type-IBM-XML}),
    substitute ("отсутствует путь к подкаталогу out" + {&new-line} + "для отсылки информации на POS &1", {&cd-type-IBM-XML}),
    yes,
    output in_) no-error.
if error-status:error or in_ = ? then return error return-value .
RUN verify-file in this-procedure
    ( in_
    , substitute("Не найден каталог &1 параметр in, секция [kassa-&2] ini-файла", in_, {&cd-type-IBM-XML})
    ,yes
    ,output glog) no-error.
if error-status:error or not glog then return error return-value .

run verify-ini-entry("out":U,
    substitute("kassa-&1":U, {&cd-type-IBM-XML}),
    substitute ("отсутствует путь к подкаталогу out" + {&new-line} + "для отсылки информации на POS &1", {&cd-type-IBM-XML}),
    yes,
    output out) no-error.
if error-status:error or out = ? then return error return-value .
run verify-file in this-procedure
    ( out
    , substitute("Не найден каталог &1 параметр out, секция [kassa-&2] ini-файла", out, {&cd-type-IBM-XML})
    , yes
    ,output glog) no-error.
if error-status:error or not glog then return error return-value .

run gbl/dir-cre.p ( input in_ + 'Report\') no-error .
if error-status:error then 
do:
    return error substitute(
        "!!!Каталог &1 не найден&2" +
        "и/или попытка его создания не удалась:&2&3 &4"
        , in_ + 'Report\'
        , {&new-line}
        , error-status:get-message(1)
        , return-value
        ).
end.

run gbl/dir-cre.p ( input out + 'Report\') no-error .
if error-status:error then 
do:
    return error substitute(
        "!!!Каталог &1 не найден&2" +
        "и/или попытка его создания не удалась:&2&3 &4"
        , out + 'Report\'
        , {&new-line}
        , error-status:get-message(1)
        , return-value
        ).
end.

run MainProc no-error.
if error-status:error then 
do:
    return error return-value.
end.

procedure MainProc:
    define buffer cash-desk for cash-desk.
   
    define variable vMsg as character no-undo.
   
    _cash-desk:
    FOR EACH cash-desk WHERE
        cash-desk.db-num   = g#db-num
        and cash-desk.obj-code = p-obj-code
        and cash-desk.pos-type = {&cd-type-IBM-XML}
        and cash-desk.cash-on  = yes
        no-lock:
        empty temp-table tt-chk-report-head.
        empty temp-table tt-chk-report-string.
        assign
            m-xml-file-name      = substring(string( next-value( s-spool, {&db-name_schema}), '99999999999999999999'), 13, 8 )
            m-obj-list           = {&shop} + "_" + string(cash-desk.obj-code)
            m-correspondent      = ("касса_" + string(cash-desk.cash-num) + "_" + m-obj-list)
            m-post-file-name     = replace(out + "Report/" + m-xml-file-name, "/", "\" ) + ".xml":U
            m-response-file-name = replace(in_ + "Report/" + m-xml-file-name, "/", "\" ) + ".xml":U
            m-obj-code           = cash-desk.obj-code
            m-pos-type           = cash-desk.pos-type
            m-cash-num           = cash-desk.cash-num
            mCount               = 0
            .

        run pGetLastTStamp(m-obj-code,
            m-pos-type,
            m-cash-num,
            output m-timestamp).
        m-time = m-timestamp .
        run write-log-and-file in p-log-handle (
            input 1
            , input p-log-file-name
            , input 1
            , input substitute('Получаем данные кассовых отчетов с кассы &1://&2'
            ,entry(1, cash-desk.addr-path, {&delim-par})
            ,entry(2, cash-desk.addr-path, {&delim-par})
            )
            ).
    
        run SaxWriter no-error.
        if error-status:error then 
        do:
            return error return-value.
        end.
        mWriteRespFile = m-response-file-name + "sckt".
        run ConectSocet (entry(1,entry(2, cash-desk.addr-path, {&delim-par}),":"),
            entry(2,entry(2, cash-desk.addr-path, {&delim-par}),":"),
            "",
            Mreq,
            "xml",
            300,
            no,
            substitute ("Чтение данных кассовых отчетов с кассы &1. ",entry(2, cash-desk.addr-path, {&delim-par}))
            ).
        if    mWebResp eq ""
            or OerrMsg  ne ""
            then 
        do:
            run write-log-and-file in p-log-handle (
                input 1
                , input p-log-file-name
                , input 1
                , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                ,cash-desk.cash-num
                ,cash-desk.obj-code
                , {&new-line}
                , OerrMsg
                /*                                , return-value*/
                )
                ).
            nEXT _cash-desk.
        end.
        else 
        do:
            run write-log-and-file in p-log-handle (
                input 1
                , input p-log-file-name
                , input 1
                , input substitute('Время ожидания выполнения задания на кассе - &1 c',
                mSocetEndTime
                )
                ).
        end.

        run SaxReader no-error.
        if ErrorMessage <> "" or error-status:error then 
        do:
            return error ErrorMessage + " " + return-value.
        end.

        do transaction:

            for each tt-chk-report-head where
                tt-chk-report-head.cash-num = m-cash-num: 
                find first chk-slip-head where
                    chk-slip-head.db-num       = tt-chk-report-head.db-num
                    and chk-slip-head.ID       = tt-chk-report-head.ID
                    and chk-slip-head.CheckID  = tt-chk-report-head.CheckID
                    and chk-slip-head.RRN      = tt-chk-report-head.RRN
                    no-lock no-error.
                if not avail chk-slip-head then 
                do:
                    create chk-slip-head .
                    buffer-copy tt-chk-report-head to chk-slip-head .
                    for each tt-chk-report-string no-lock where 
                        tt-chk-report-string.db-num  = tt-chk-report-head.db-num
                        and tt-chk-report-string.ID      = tt-chk-report-head.ID
                        and tt-chk-report-string.CheckID = tt-chk-report-head.CheckID
                        and tt-chk-report-string.RRN     = tt-chk-report-head.RRN
                        :
                        find first chk-slip-string where
                            chk-slip-string.db-num    = tt-chk-report-string.db-num
                            and chk-slip-string.ID        = tt-chk-report-string.ID
                            and chk-slip-string.CheckID   = tt-chk-report-string.CheckID
                            and chk-slip-string.RRN       = tt-chk-report-string.RRN
                            and chk-slip-string.str-num   = tt-chk-report-string.str-num
                            no-lock no-error.
                        if not avail chk-slip-string then
                        do:
                            create chk-slip-string .
                            buffer-copy tt-chk-report-string to chk-slip-string .
                        end .
                    end .
                    mCount = mCount + 1.
                end.
            end.
            vMsg = "Загружено ФО: " + string(mCount).
            run write-log-and-file in p-log-handle (
                input 1
                , input p-log-file-name
                , input 1
                , input vMsg).
            p-ok = true.
  
 
            find last chk-slip-head no-lock where chk-slip-head.cash-num = cash-desk.cash-num and
                chk-slip-head.obj-code = cash-desk.obj-code and
                chk-slip-head.db-num = cash-desk.db-num and
                chk-slip-head.is-report = 1 no-error .    
            define variable v-value as character no-undo .
            define variable v-time1 as character no-undo .
            define variable v-time  as character no-undo .

            v-time1 = entry(2,string(chk-slip-head.slip-dt)," ") .    
            v-time =  entry(1,v-time1,".") .  
            v-value = string(YEAR(date(chk-slip-head.slip-dt)), "9999":U) + "-":U +
                string(Month(date(chk-slip-head.slip-dt)), "99":U) + "-":U +
                string(DAY(date(chk-slip-head.slip-dt)), "99":U) .

                    
  run cd-attr-write in this-procedure (
                                         input cash-desk.db-num
                                        ,input cash-desk.obj-code
                                        ,input cash-desk.pos-type
                                        ,input cash-desk.cash-num
                                        ,input (if cash-desk.pos-type = {&cd-type-ibm-xml}
                                                then {&cda-ibm-xml_operative}
                                                else if cash-desk.pos-type = {&cd-type-autotank}
                                                then {&cda-autotank_operative} else "")
                                        ,input (if cash-desk.pos-type = {&cd-type-ibm-xml}
                                                then {&cda-ibm-xml_operative_last-report-params}
                                                else if cash-desk.pos-type = {&cd-type-autotank}
                                                then {&cda-autotank_operative_last-report-params}
                                                else "")
                                        ,input (v-value + {&space-char} + v-time
                                             +  (if cash-desk.pos-type = {&cd-type-ibm-xml}
                                                 or cash-desk.pos-type = {&cd-type-autotank}
                                               then ({&space-char} + string(chk-slip-head.CashShiftNum) )
                                               else  "":U)
                                               )                                               
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                        ) no-error.
                                        
end.
end.
  /*отправка отчетов в 1С*/
  define variable slip-dt as character no-undo .
  define buffer buf_chk-slip-head for ub.chk-slip-head .
  if m-time = "0" then slip-dt = string(01/01/1900) . else slip-dt = string(fConvetDateTime(m-time)) .


          find first buf_chk-slip-head no-lock where buf_chk-slip-head.db-num = g#db-num and
          buf_chk-slip-head.obj-code = p-obj-code and
          buf_chk-slip-head.is-report = 1 and
          buf_chk-slip-head.slip-dt > datetime(slip-dt) no-error .
          if available (buf_chk-slip-head) then do:
          
          run bge\send1cerp.p (parparentproc,
            this-procedure,
            this-procedure,
            "chkSlipHead",
            (buffer buf_chk-slip-head:handle),
            ?,                       
            ?) no-error.
        if  error-status:error then 
        do: 
            message return-value
                view-as alert-box.  
            return .
        end.          
        end.  
end procedure.

procedure pGetLastTStamp:
    define input  parameter p-obj-code as integer   no-undo.
    define input  parameter p-pos-type as character no-undo.
    define input  parameter p-cash-num as integer   no-undo.
    define output parameter oTStamp    as character no-undo.
   
    define buffer chk-slip-head for chk-slip-head.
   
    define variable v-last-date      as date    no-undo .
    define variable v-last-time      as integer no-undo .
    define variable v-last-shift-num as integer no-undo .
    define variable v-last-z-count   as integer no-undo .
    define variable v-last-chk-num   as integer no-undo .
   
    run get-last-report-params in this-procedure ( input g#db-num
        ,input p-obj-code
        ,input p-pos-type
        ,input p-cash-num
        ,output v-last-date
        ,output v-last-time
        ,output v-last-shift-num
        ) no-error.
    if v-last-date <> ? then 
        oTStamp = string( ( v-last-date - date( "01/01/1970" ) ) * 24 * 3600 + v-last-time - Timezone * 60 - 1 * 60 * 60, ">>>>>>>>>9" ). /* Дополнительно сдвинем на 1 час назад */
    else
        oTStamp = "0".

end procedure.

procedure SaxWriter: /* Запос */
    define variable hSAXWriter as handle no-undo.
    create sax-writer hSAXWriter.
    hSAXWriter:set-output-destination("longchar", Mreq) no-error.
    hSAXWriter:formatted = true.
    hSAXWriter:encoding = "windows-1251".

    hSAXWriter:start-document() no-error.

    hSAXWriter:start-element("reports") no-error.
    hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
    hSAXWriter:insert-attribute("id",     m-xml-file-name) no-error.
    hSAXWriter:insert-attribute("from",   m-obj-list)      no-error.
    hSAXWriter:insert-attribute("to",     m-correspondent) no-error.
    hSAXWriter:insert-attribute("tstamp", m-timestamp)     no-error.
    hSAXWriter:end-element("reports") no-error.

    hSAXWriter:end-document() no-error.
    if hSAXWriter:write-status = 7 then 
    do:
        delete object hSAXWriter no-error.
        return error.
    end.
    delete object hSAXWriter no-error.
    
end.

procedure SaxReader:
    define variable hParser as handle no-undo.
  
    create sax-reader hParser.
    define variable vmemptr as memptr no-undo.
    copy-lob mWebResp to vmemptr.
    hParser:set-input-source("memptr", vmemptr).
    hParser:sax-parse () no-error.
    if error-status:error then 
    do:
        if error-status:num-messages > 0 then
            /* unable to begin the parse */
            return error error-status:get-message(1).
        else
            /* error detected in a callback */
            return error return-value.
    end.
    delete object hParser.
end.

/* SAXCallbacks */

/* Invoked when the XML parser detects the start of an XML document. */
PROCEDURE StartDocument:

END PROCEDURE.

/* Invoked when the XML parser detects the beginning of an element. */
PROCEDURE StartElement:
    DEFINE INPUT PARAMETER namespaceURI AS CHARACTER.
    DEFINE INPUT PARAMETER localName AS CHARACTER.
    DEFINE INPUT PARAMETER qname AS CHARACTER.
    DEFINE INPUT PARAMETER attributes AS HANDLE.
  
    mElement = qname.
    if mElement = "report" then 
    do:
        if attributes:GET-VALUE-BY-QNAME("code") <> ? then 
        do:
            empty temp-table tt-one-chk-report-head.
            create tt-one-chk-report-head.
            assign
                tt-one-chk-report-head.db-num    = g#db-num
                tt-one-chk-report-head.obj-code  = m-obj-code
                tt-one-chk-report-head.ID        = attributes:GET-VALUE-BY-QNAME("code")
                tt-one-chk-report-head.is-report = 1
                .
        end.
    end.
    if mElement = "STextCheq" then 
    do:
        m-textCheq = "" .
    end .
    if mElement = "SParamJSON" then 
    do:
        m-ParamJSON = "" .
    end .
END PROCEDURE.

/* Invoked when the XML parser detects character data. */
PROCEDURE Characters:
    DEFINE INPUT PARAMETER charData AS MEMPTR.
    DEFINE INPUT PARAMETER numChars AS INTEGER.
  
    define variable vCurrContent  as longchar no-undo.
    define variable vLengthMemptr as int64    no-undo.
    define variable vReadByte     as int64    no-undo.
    define variable vRead         as integer  no-undo.
  
    vLengthMemptr = numChars.
    do while vLengthMemptr - vReadByte > 0 :
        vRead = min(vLengthMemptr - vReadByte,30000).
        vCurrContent = vCurrContent + GET-STRING(charData,vReadByte + 1,vRead).
        vReadByte = vReadByte + vRead.
    end. 
    if trim(vCurrContent) = "" then return.

    case mElement:
        when "SUuidCheq" then
            tt-one-chk-report-head.CheckID = vCurrContent .   
        when "SRRN" then
            tt-one-chk-report-head.RRN = vCurrContent .     
        when "SDate" then
            tt-one-chk-report-head.slip-dt = fConvetDateTime(string(vCurrContent)) no-error.
        when "ShiftDate" then
            tt-one-chk-report-head.CashShiftDate = fConvetDate(string(vCurrContent)) no-error.
        when "ShiftNum" then
            tt-one-chk-report-head.CashShiftNum = integer(vCurrContent) no-error.
        when "SProc" then
            tt-one-chk-report-head.proc-type = integer(vCurrContent) no-error.
        when "RSrc" then
            tt-one-chk-report-head.src_ = integer(vCurrContent) no-error.
        when "RType" then
            tt-one-chk-report-head.kind = integer(vCurrContent) no-error.
        when "Report" then
            tt-one-chk-report-head.is-report = integer(vCurrContent) no-error.
        when "KassaNumber" then
            tt-one-chk-report-head.cash-num = integer(vCurrContent) no-error.
        when "SParamJSON" then 
            do :
                m-ParamJson = m-ParamJson + vCurrContent .
            end .
        when "ErrorMessage" then
            ErrorMessage = vCurrContent.
        when "STextCheq"
        then 
            do :
                m-textCheq = m-textCheq + vCurrContent .
            end .
    end case.

END PROCEDURE.

/* Invoked when the XML parser detects the end of an element. */
PROCEDURE EndElement:
    DEFINE INPUT PARAMETER name_ AS CHARACTER.
    DEFINE INPUT PARAMETER localName AS CHARACTER.
    DEFINE INPUT PARAMETER qName AS CHARACTER.
  
    define variable ii as integer no-undo .
    
    if qname = "ErrorMessage" then 
    do:
        /*      ErrorMessage = mcurrentContent.*/
        self:stop-parsing ().
    end.
    else
        if qName = "report" then 
        do:
            if tt-one-chk-report-head.ID > "" and tt-one-chk-report-head.cash-num > 0
                then 
            do :
                find first tt-chk-report-head where tt-chk-report-head.db-num    = tt-one-chk-report-head.db-num
                    and tt-chk-report-head.ID        = tt-one-chk-report-head.ID
                    no-error .
                if not available tt-chk-report-head
                    then 
                do :
                    create tt-chk-report-head .
                    buffer-copy tt-one-chk-report-head to tt-chk-report-head .
                end .  
            end .
        end.
    if qName = "STextCheq" then 
    do:
        if tt-one-chk-report-head.ID > ""
            then 
        do :
            do ii = 1 to num-entries(m-textCheq, {&new-line}) :
                create tt-chk-report-string.
                assign 
                    tt-chk-report-string.db-num    = tt-one-chk-report-head.db-num
                    tt-chk-report-string.ID        = tt-one-chk-report-head.ID
                    tt-chk-report-string.CheckID   = tt-one-chk-report-head.CheckID
                    tt-chk-report-string.RRN       = tt-one-chk-report-head.RRN
                    tt-chk-report-string.str-num   = ii
                    tt-chk-report-string.str-value = entry(ii, m-textCheq, {&new-line})
                    .
            end .
        end .
    end.    
    if qName = "SParamJSON" then 
    do:
        if tt-one-chk-report-head.ID > ""
            then 
        do :
            do ii = 10001 to num-entries(m-ParamJson, {&new-line}) :
                create tt-chk-report-string.
                assign 
                    tt-chk-report-string.db-num    = tt-one-chk-report-head.db-num
                    tt-chk-report-string.ID        = tt-one-chk-report-head.ID
                    tt-chk-report-string.CheckID   = tt-one-chk-report-head.CheckID
                    tt-chk-report-string.RRN       = tt-one-chk-report-head.RRN                    
                    tt-chk-report-string.str-num   = ii
                    tt-chk-report-string.str-value = entry(ii, m-ParamJson, {&new-line})
                    .
            end .
        end .        
    end .

END PROCEDURE.

/* Invoked when the XML parser detects the end of an XML document. */
PROCEDURE EndDocument:
    p-ok = true.

END PROCEDURE.

/* Invoked to report a warning. */
PROCEDURE Warning:
    DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
    MESSAGE "The following WARNING was generated:~n" + ErrMessage
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.
    
/* Invoked to report an error encountered by the parser while parsing the XML document. */
PROCEDURE Error:
    DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
    p-ok = false.
    MESSAGE "The following NONFATAL ERROR was generated:~n" + ErrMessage
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.

/* Invoked to report a fatal error. */
PROCEDURE FatalError:
    DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
    p-ok = false.
    RETURN ERROR "The following FATAL ERROR was generated:~n" + ErrMessage.
END PROCEDURE.

