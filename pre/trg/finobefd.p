block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.fin-ob-before.
define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Триггер на yдаление пред финансового обязательства ".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
    assign
      p-vss-parameters = substitute('&1|&2', ub.fin-ob-before.before-code, ub.fin-ob-before.host-code)
    .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
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
main-block :
do transaction
on error undo main-block, return error
:
define buffer other_fin-ob for fin-ob.
define buffer other_fin-ob-before for fin-ob-before.
define buffer other_fin-ob-trn for fin-ob-trn.
define variable v-trn-code as character no-undo .
define variable v-fin-ob as character no-undo .
define variable v-col-fin-ob as integer no-undo .
define variable v-type-pay-orig  as character no-undo .
define variable v-type-pay       as character no-undo .
define variable v-pay as character no-undo .
define variable v-ok as logical no-undo .
define variable v-not-flag as logical no-undo .
define variable v-galki as logical no-undo .
find first contract no-lock where  contract.contract-code = fin-ob-before.contract-code no-error .
v-ok = true .
if lookup ( contract.usl-opl , 'По факту поставки,Отсрочка платежа (по поставке)' ) > 0
   then
     assign
      v-type-pay-orig = "по поставке"
      v-pay = 'По факту поставки,Отсрочка платежа (по поставке)'
     .
   else
     assign
        v-type-pay-orig = "по реализации"
        v-pay = 'По факту реализации,По реализации части приход. накладной,Отсрочка платежа (по реализации)'
     .
for each fin-ob-trn no-lock where fin-ob-trn.doc-code  = fin-ob-before.before-code
    on error undo, return error :
    v-trn-code = fin-ob-trn.trn-doc-code.
    v-fin-ob =  "" .
    v-col-fin-ob =  0 .
        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob-before.before-code ,
            first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + " ФО " + string(other_fin-ob-trn.doc-code) + "," .
            v-col-fin-ob = v-col-fin-ob + 1.
        end.
        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob-before.before-code ,
            first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + "  ПФО " + string(other_fin-ob-trn.doc-code).
            v-col-fin-ob = v-col-fin-ob + 1.
        end.
    if v-col-fin-ob > 0 then
    message "ПредФинОбязательство было создано по накладной  " v-trn-code skip
             "Тип оплаты : " v-type-pay-orig skip
             "По этой же накладной было одновременно создано еще : " v-col-fin-ob   skip
             "Вн. номера : " v-fin-ob                                     skip
             "По накладной ФО и ПФО автоматически генерируются один раз "  skip
             "   по одному типу оплаты (поставке или реализации)       "  skip
             " "                                                          skip  skip
             "( ДА  - удалить ПФО " fin-ob-before.before-code " , "  skip
             "      без возможности повторной автоматической генерации по накладной "  skip
             " НЕТ - не удалять ) "
             view-as alert-box question
             buttons yes-no
             title "Вопрос"
             update v-ok
             .
end.
if v-ok = false then   UNDO , RETURN ERROR.
    for each fin-ob-tax-before where
        fin-ob-tax-before.before-code  = fin-ob-before.before-code  and
        fin-ob-tax-before.host-code    = fin-ob-before.host-code
        on error undo main-block, return error
        :
          delete  fin-ob-tax-before.
    end.
    for each fin-ob-trn no-lock where
        fin-ob-trn.doc-code  = fin-ob-before.before-code  and
        fin-ob-trn.host-code = fin-ob-before.host-code
        on error undo main-block, return error
        :
        for each trn-doc  exclusive-lock   where
          trn-doc.doc-code = fin-ob-trn.trn-doc-code
            on error undo main-block, return error  :
            v-galki = true .
                for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                        other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                    first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
                      first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                                    lookup( contract.usl-opl , v-pay ) > 0
                      on error undo, return error :
                      v-galki = false .
                end.
                for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                        other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                    first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
                      first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                                    lookup( contract.usl-opl , v-pay ) > 0
                      on error undo, return error :
                      v-galki = false .
                end.
                  if v-galki = true  then do:
                      if v-pay = 'По факту реализации,По реализации части приход. накладной,Отсрочка платежа (по реализации)' then do:
                          assign
                              trn-doc.cr-expfo    = false
                              trn-doc.expfo-date  = 01/01/1990
                          no-error .
                      end.
                      else do:
                          assign
                              trn-doc.cr-incfo    = false
                              trn-doc.incfo-date  = 01/01/1990
                          no-error .
                      end.
                        if error-status :error then
                        message vss-workfile vss-revision vss-description skip
                            "Ошибка корректировки накладной" skip
                            error-status :get-message(1)
                            view-as alert-box information .
                      if trn-doc.cr-expfo = false and
                         trn-doc.cr-incfo = false then do:
                        assign
                          trn-doc.cr-incorexpfo = false.
                      end.
                  end.
        end.
    end.
    for each fin-ob-trn where
        fin-ob-trn.doc-code  = fin-ob-before.before-code  and
        fin-ob-trn.host-code = fin-ob-before.host-code
        on error undo main-block, return error
        :
          delete  fin-ob-trn.
    end.
    for each fin-gds-part where
        fin-gds-part.fin-ob-code  = fin-ob-before.before-code  and
        fin-gds-part.host-code    = fin-ob-before.host-code
        on error undo main-block, return error
        :
          delete  fin-gds-part.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'fin-ob-before':U
        , input ( buffer ub.fin-ob-before:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
