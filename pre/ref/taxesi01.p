block-level on error undo, throw.
DEFINE TEMP-TABLE tt-tax-units NO-UNDO LIKE ub.tax-units
       field is-found as logical column-label ""
       index pi is unique primary tax-code type.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter partax-code like ub.tax.tax-code no-undo .
define input parameter partax-name like ub.tax.tax-name no-undo .
define input parameter partax-type like ub.tax.tax-type no-undo .
define input parameter par-individual like ub.tax.individual no-undo .
define input parameter parto-cashdesk like ub.tax.to-cashdesk no-undo .
define input parameter table for tt-tax-units.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: taxesi01.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/taxesi01.p $":U .
def var vss-description as character no-undo init "Сохранение изменений в карточке налога".
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
DEFINE VARIABLE II AS INTEGER NO-UNDO.
define variable var-entry as character no-undo .
def var update-recid as recid no-undo.
if g#db-num > 0 then do:
  message  vss-workfile vss-revision vss-description skip
          "Вызов процедуры в УБД запрещен"
  view-as alert-box ERROR.
  return error '':U.
end.
if partax-name = "" then do:
  message "Укажите полное наименование." view-as alert-box WARNING .
  var-entry = "tax-name":U.
  return error var-entry.
end.
if partax-code = 0 or
    partax-code = ? then do:
  message "Укажите код." view-as alert-box WARNING .
  var-entry =  "tax-code":U.
  return error var-entry.
end.
if integer(partax-code) < 4 + 1 then do:
  message "Значения кодов меньшие" (4 + 1) "зарезервированы," SKip
          "можно изменить только параметр отсылки на кассу"
  view-as alert-box WARNING .
end.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  if can-find( ub.tax where
               ub.tax.tax-code = integer(partax-code )) then  do:
    message "Налог с таким кодом уже есть." view-as alert-box ERROR .
    var-entry =  "tax-code":U.
    return error var-entry.
  end.
  if parto-cashdesk =  yes and
     par-individual = yes  AND
     can-find(first ub.tax No-LOCK WHERE
                    ub.tax.to-cashdesk = yes AND
                    ub.tax.individual = yes) then  do:
    message "В связи с особенностями работы POS IBM" skip
            "количество определенных в системе " skip
            "индивидуальных налогов, пересылаемых на кассу"
            "не может быть больше одного" view-as alert-box ERROR .
    var-entry =  "individual":U.
    return error var-entry.
  end.
  CREATE ub.tax.
  assign
  ub.tax.tax-code = partax-code
  ub.tax.tax-name = partax-name
  ub.tax.tax-type = if (parTAX-TYPE = 'процентный':U)
                then '%':U
                else 'abs':U
  ub.tax.to-cashdesk = parto-cashdesk
  ub.tax.individual = par-individual
  ub.tax.status_ = 'тек':U
  par-rid = recid( ub.tax )
  .
  for each tt-tax-units where
          tt-tax-units.tax-code = partax-code:
      if tt-tax-units.is-found then do:
        create ub.tax-units.
        assign
        ub.tax-units.tax-code = partax-code
        ub.tax-units.type = tt-tax-units.type
        .
      end.
  END.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U then do:
  FIND FIRST tax where
             recid(tax) = par-rid No-ERROR.
  if error-status:error then return error '':U.
  if parto-cashdesk =  yes and
     par-individual = yes  AND
     can-find(first tax No-LOCK WHERE
                    tax.to-cashdesk = yes AND
                    tax.individual = yes AND
                    recid(tax) <> par-rid) then  do:
    message "В связи с особенностями работы POS IBM" skip
            "количество определенных в системе " skip
            "индивидуальных налогов, пересылаемых на кассу"
            "не может быть больше одного" view-as alert-box ERROR .
    var-entry =  "individual":U.
    return error var-entry.
  end.
  if  integer(partax-code) < 4 + 1 then do:
    assign
    tax.to-cashdesk = parto-cashdesk
    par-rid = recid(tax).
  end.
  else do:
    assign
    tax.to-cashdesk = parto-cashdesk
    tax.tax-name = partax-name
    par-rid = recid(tax).
  end.
  if integer(partax-code) > 4 + 1 then do:
    for each tt-tax-units where
            tt-tax-units.tax-code = partax-code:
      if tt-tax-units.is-found then do:
        find first ub.tax-units where
              ub.tax-units.tax-code = partax-code AND
              ub.tax-units.type= tt-tax-units.type No-ERROR.
        if not avail ub.tax-units then do:
          create ub.tax-units.
          assign
          ub.tax-units.tax-code = partax-code
          ub.tax-units.type = tt-tax-units.type
          .
        end.
      end.
      else do:
        find first ub.tax-units where
              ub.tax-units.tax-code = partax-code AND
              ub.tax-units.type= tt-tax-units.type No-ERROR.
        if avail ub.tax-units then do:
          delete ub.tax-units.
        end.
      end.
    END.
  END.
end.
return '':U.
