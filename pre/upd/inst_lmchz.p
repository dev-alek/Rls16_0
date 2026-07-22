block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.
define variable mAddress  as character no-undo.
define variable mCommand as character no-undo.
define variable mIp     as character no-undo .
define variable mPort   as character no-undo .
define variable mLogin  as character no-undo .
define variable mPass   as character no-undo .
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
mAddress = entry(lookup("Address",iparam,chr(4)) + 1,iParam,chr(4)).
mCommand = entry(lookup("Command",iparam,chr(4)) + 1,iParam,chr(4)).
function ChgV1 return logical
    (input p-obj-type as char,
     input p-obj-code as int) forward.
if mCommand <> "" then
do:
    run getSettingsGisMt in this-procedure.
    if mLogin = "" or mPass = ""
    then do:
       oOk = false.
       return error "Не заполнены логин и/или пароль в ЛМ ЧЗ".
    end.
    run runBatLmCHz in this-procedure (output oOk).
    if not oOk then
       return error "Возникала ошибка при установки ЛМ ЧЗ".
end.
if mAddress <> "" then
do:
  oOk = ChgV1('БД':U,g#db-num).
  if oOk and g#db-num = 0 then oOk = ChgV1("",g#db-num).
end.
procedure runBatLmCHz:
    define output parameter oResult as logical no-undo.
    define variable vRunCmd as character no-undo.
    assign
      vRunCmd = replace(mCommand, "%Адрес прокси%",    mIp)
      vRunCmd = replace(vRunCmd, "%Порт прокси%",  mPort)
      vRunCmd = replace(vRunCmd, "%Логин ЛМ ЧЗ%", mLogin)
      vRunCmd = replace(vRunCmd, "%Пароль ЛМ ЧЗ%",  mPass)
    .
    os-command value (substitute ("&2 &1 exit" ,chr(38), vRunCmd)).
    oResult = os-error = 0.
end procedure.
procedure getSettingsGisMt:
    define variable vDbNum          as integer   no-undo.
    define variable vValueCharacter as character no-undo .
    define variable vValueDate      as date      no-undo .
    define variable vValueDecimal   as decimal   no-undo .
    define variable vValueInteger   as INTEGER   no-undo .
    define variable vValueLogical   as LOGICAL   no-undo .
    define variable vParamType      as character no-undo .
    define variable vBufferTT       as handle    no-undo .
    define buffer sys-ctrl for ub.sys-ctrl.
    find first sys-ctrl no-lock no-error.
    vDbNum = sys-ctrl.db-num.
    vBufferTT      = buffer temp-thbj-attr:table-handle .
    run adm/shattri.p (
          input "init":U
        , input 'БД':U
        , input vDbNum
        , input 'gisMT':U
        , input "":U
        , output vValueCharacter
        , output vValueDate
        , output vValueDecimal
        , output vValueInteger
        , output vValueLogical
        , output vParamType
        , input-output TABLE-HANDLE vBufferTT
        ) no-error .
    for first temp-thbj-attr where
              temp-thbj-attr.prop-code = 'adressPort':U
    :
      if temp-thbj-attr.property-value-character <> "" then
      do:
        mIp   = entry(1,temp-thbj-attr.property-value-character,":").
        mPort = if num-entries(temp-thbj-attr.property-value-character,":") > 1
                then entry(2,temp-thbj-attr.property-value-character,":") else "".
      end.
    end.
    for first temp-thbj-attr where
              temp-thbj-attr.prop-code = 'OflineLogin':U
    :
      mLogin = temp-thbj-attr.property-value-character.
    end.
    for first temp-thbj-attr where
              temp-thbj-attr.prop-code = 'OflinePswd':U
    :
      mPass  = temp-thbj-attr.property-value-character.
    end.
end procedure.
function ChgV1 return logical
    (input p-obj-type as char,
     input p-obj-code as int):
    define variable vOk as logical no-undo.
    define buffer thbj-attr for ub.thbj-attr.
    do trans:
        vOk = true.
        find first thbj-attr where thbj-attr.upper-prop-code eq 'gisMT':U
                             and thbj-attr.obj-type        eq p-obj-type
                             and thbj-attr.obj-code        eq p-obj-code
                             and thbj-attr.prop-code       eq 'OflineAdress':U
        exclusive-lock no-wait no-error.
        if available thbj-attr then do:
           thbj-attr.property-value-character = mAddress .
        end.
        else if locked thbj-attr then vOk = false.
    end.
    return vOk.
end.
