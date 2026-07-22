block-level on error undo, throw.
{ cmp/trg-def.i  }
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

define variable mAddress  as character no-undo.
define variable mCommand as character no-undo.
define variable mIp     as character no-undo .
define variable mPort   as character no-undo .
define variable mLogin  as character no-undo .
define variable mPass   as character no-undo .

&scoped-define MASK_IP    %Адрес прокси%
&scoped-define MASK_PORT  %Порт прокси%
&scoped-define MASK_LOGIN %Логин ЛМ ЧЗ%
&scoped-define MASK_PASS  %Пароль ЛМ ЧЗ%
    
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.

mAddress = entry(lookup("Address",iparam,{&delim-par}) + 1,iParam,{&delim-par}).
mCommand = entry(lookup("Command",iparam,{&delim-par}) + 1,iParam,{&delim-par}).
/*run gbl/inidebug.p.*/

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
  /* меняем текущую локальную секцию */
  oOk = ChgV1({&db},g#db-num).
  /* для ТБД меняем глобальную секцию */
  if oOk and g#db-num = 0 then oOk = ChgV1("",g#db-num).
end.

procedure runBatLmCHz:
    define output parameter oResult as logical no-undo.
    
    define variable vRunCmd as character no-undo. 

    assign
      vRunCmd = replace(mCommand, "{&MASK_IP}",    mIp)
      vRunCmd = replace(vRunCmd, "{&MASK_PORT}",  mPort)
      vRunCmd = replace(vRunCmd, "{&MASK_LOGIN}", mLogin)
      vRunCmd = replace(vRunCmd, "{&MASK_PASS}",  mPass)
    .
    os-command value (substitute ("&2 &1 exit" ,{&ampersand}, vRunCmd)).
    oResult = os-error = 0.
end procedure.

/* процедура получения настроек ГИС МТ */
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
        , input {&db}
        , input vDbNum
        , input {&attr-gisMT}
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
              temp-thbj-attr.prop-code = {&attr-gisMT_adressPort}
    :
      if temp-thbj-attr.property-value-character <> "" then 
      do:
        mIp   = entry(1,temp-thbj-attr.property-value-character,":").
        mPort = if num-entries(temp-thbj-attr.property-value-character,":") > 1 
                then entry(2,temp-thbj-attr.property-value-character,":") else "".
      end.
    end.
    for first temp-thbj-attr where
              temp-thbj-attr.prop-code = {&attr-gisMT_OflineLogin}
    :
      mLogin = temp-thbj-attr.property-value-character.
    end.
    for first temp-thbj-attr where
              temp-thbj-attr.prop-code = {&attr-gisMT_OflinePswd}
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
        find first thbj-attr where thbj-attr.upper-prop-code eq {&attr-gisMT}
                             and thbj-attr.obj-type        eq p-obj-type
                             and thbj-attr.obj-code        eq p-obj-code
                             and thbj-attr.prop-code       eq {&attr-gisMT_OflineAdress}                           
        exclusive-lock no-wait no-error.
        if available thbj-attr then do:
           thbj-attr.property-value-character = mAddress .
        end.
        else if locked thbj-attr then vOk = false.
        
    end.
    return vOk.
end.

