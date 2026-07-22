block-level on error undo, throw.
define input  parameter pobj-type like ub.clients.obj-type     no-undo.
define input  parameter pobj-code like ub.clients.obj-code     no-undo.
define input  parameter ppl-code  like ub.place.pl-code        no-undo.
define input  parameter pgds-code like ub.goods.gds-code       no-undo.
define output parameter parresult as logical                   no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Связывание резервуара с топливом" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function nzpl-spl returns logical
(input p-obj-type as character
                                , input p-obj-code as integer):
define variable v-dopi    as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-tth as handle no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type1 as character no-undo .
define variable v-value-date1 as date no-undo .
define variable v-value-decimal1 as decimal no-undo .
define variable v-value-integer1 as INTEGER no-undo .
define variable v-value-logical1 AS LOGICAL no-undo .
define variable v-tth1 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date1
    ,output v-value-decimal1
    ,output v-value-integer1
    ,output v-value-logical1
    ,output v-param-type1
    ,INPUT-OUTPUT table-handle v-tth1
    ) no-error .
delete object v-tth1 no-error.
if dflt-cd <> 'IBM':U
and dflt-cd <> 'IBM-XML':U then return no.
if dflt-cd = 'IBM-XML':U then return yes.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-type-ibm':U
    ,input  'ibmspool':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return no.
end.
delete object v-tth.
assign
v-dopi = v-value-integer no-error .
if v-dopi >= 6 then return yes.
end. // FUNCTION/method
FUNCTION nzpl-two returns logical
                                 (input p-obj-type as character
                                  , input p-obj-code as integer):
  define variable v-nzpl-two as logical no-undo.
  run
  nzpl-two-proc (input p-obj-type, input p-obj-code, output v-nzpl-two).
  return v-nzpl-two.
end. // FUNCTION/method
procedure nzpl-two-proc :
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define output parameter varge-two-pl as logical   no-undo.
define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
//do on error undo, return error return-value :
assign
  varge-two-pl = no.
for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = p-obj-type        and
                              bf_pl-gds-pump.obj-code = p-obj-code        and
                              bf_pl-gds-pump.status_  = 'тек':U no-lock on error undo, return error return-value :
  find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                                        bf-other_pl-gds-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                                        bf-other_pl-gds-pump.pump-code =  bf_pl-gds-pump.pump-code and
                                        bf-other_pl-gds-pump.gds-code  =  bf_pl-gds-pump.gds-code  and
                                        bf-other_pl-gds-pump.status_   =  'тек':U        and
                                        bf-other_pl-gds-pump.pl-code   <> bf_pl-gds-pump.pl-code   no-lock no-error.
  if available bf-other_pl-gds-pump then do:
    assign
      varge-two-pl = yes.
    leave.
  end.
end.
//end.
end. // procedure/method .
procedure cplgdspm :
  define input parameter parobj-type  like ub.pl-gds-pump.obj-type  no-undo.
  define input parameter parobj-code  like ub.pl-gds-pump.obj-code  no-undo.
  define input parameter parpl-code   like ub.pl-gds-pump.pl-code   no-undo.
  define input parameter pargds-code  like ub.pl-gds-pump.gds-code  no-undo.
  define input parameter parpump-code like ub.pl-gds-pump.pump-code no-undo.
  define input parameter parstatus    like ub.pl-gds-pump.status_   no-undo.
    define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
    define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
    define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer bf-place                for ub.place.
    if parstatus = 'тек':U then do:
      for each bf_pl-gds-pump no-lock
        where bf_pl-gds-pump.obj-type  =  parobj-type
          and bf_pl-gds-pump.obj-code  =  parobj-code
          and bf_pl-gds-pump.gds-code  =  pargds-code
          and bf_pl-gds-pump.pump-code =  parpump-code
          and bf_pl-gds-pump.pl-code   <> parpl-code
          and bf_pl-gds-pump.status_   =  'тек':U
      on error undo, return error
      :
        find first place where
                   place.obj-type = parobj-type
               and place.obj-code = parobj-code
               and place.pl-code  = parpl-code
             no-lock no-error.
        find first bf-place where
                   bf-place.obj-type = parobj-type
               and bf-place.obj-code = parobj-code
               and bf-place.pl-code = bf_pl-gds-pump.pl-code
             no-lock no-error.
        if nzpl-spl(parobj-type, parobj-code) <> yes then do:
          return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                     ,parobj-type
                                     ,parobj-code
                                     ,if available place then place.loc1 else string(parpl-code)
                                     ,pargds-code
                                     ,parpump-code
                                     ,parstatus
                                     ,chr(10)
                                    )
                      + substitute( "КАССА не возвращает номер пистолета в чеке, а на объекте уже есть резервуар &1 с тем же товаром и связан он с этой же ТРК."
                                    ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                  ).
        end.
        else do:
          find first bf_pl-pump-nozzle no-lock
            where bf_pl-pump-nozzle.obj-type  = parobj-type
              and bf_pl-pump-nozzle.obj-code  = parobj-code
              and bf_pl-pump-nozzle.pump-code = parpump-code
              and bf_pl-pump-nozzle.pl-code   = parpl-code
            no-error.
          if available bf_pl-pump-nozzle then do:
            find first bf-other_pl-pump-nozzle no-lock
              where bf-other_pl-pump-nozzle.obj-type  = bf_pl-gds-pump.obj-type
                and bf-other_pl-pump-nozzle.obj-code  = bf_pl-gds-pump.obj-code
                and bf-other_pl-pump-nozzle.pump-code = bf_pl-gds-pump.pump-code
                and bf-other_pl-pump-nozzle.pl-code   = bf_pl-gds-pump.pl-code
              no-error.
            if available bf-other_pl-pump-nozzle
              and bf-other_pl-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
            then do:
              return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                       ,parobj-type
                                       ,parobj-code
                                       ,if available place then place.loc1 else string(parpl-code)
                                       ,pargds-code
                                       ,parpump-code
                                       ,parstatus
                                       ,chr(10)
                                     )
                          + substitute( "На объекте &1 &2 уже есть запись резервуар &3 в статусе &4, в котором находится этот же товар и он связан с этой же ТРК через этот же пистолет."
                                        ,bf_pl-gds-pump.obj-type
                                        ,bf_pl-gds-pump.obj-code
                                        ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                        ,bf_pl-gds-pump.status_
                                      ).
            end.
          end.
        end.
      end.
    end.
end . // procedure/method
define buffer other-pl-gds-pump       for ub.pl-gds-pump.
define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
define variable v-ok      as logical   no-undo .
define variable varstatus as character no-undo.
define variable v-is-petrol-place as logical no-undo .
find first ub.pl-gds no-lock where
           ub.pl-gds.obj-type = pobj-type and
           ub.pl-gds.obj-code = pobj-code and
           ub.pl-gds.pl-code  = ppl-code
           no-error.
 if available ub.pl-gds then do:
    return error
    ("объект " + pobj-type + string(pobj-code) + chr(10) +
     "резервуар " + string(ppl-code) + " уже занят - товар " + string(ub.pl-gds.gds-code)).
 end.
find first ub.rvs-doc no-lock where
           ub.rvs-doc.obj-type = pobj-type and
           ub.rvs-doc.obj-code = pobj-code and
           ub.rvs-doc.rvs-type <> 'проверка':U and
           ub.rvs-doc.status_ <> 'факт':U  no-error.
if available ub.rvs-doc then do:
  return error
    ("объект " + pobj-type + string(pobj-code) + chr(10) +
     "сверка " + string(ub.rvs-doc.rvs-code) + " не закрыта").
end.
find first ub.icnt-doc no-lock where
           ub.icnt-doc.obj-type = pobj-type and
           ub.icnt-doc.obj-code = pobj-code and
           ub.icnt-doc.status_ <> 'факт':U no-error.
if available ub.icnt-doc then do:
  if ub.icnt-doc.doc-type = 'инв-сч-трк':U then do:
    return error
      ("объект " + pobj-type + string(pobj-code) + chr(10) +
      "инвентаризация счетчиков ТРК " + string(ub.icnt-doc.doc-code) + " не закрыта").
  end.
  if ub.icnt-doc.doc-type = 'сч-трк-погр':U then do:
    return error
      ("объект " + pobj-type + string(pobj-code) + chr(10) +
      "док-т измерения погрешности счетчиков ТРК " + string(ub.icnt-doc.doc-code) + " не закрыт").
  end.
end.
find first ub.place no-lock where
           ub.place.obj-type = pobj-type and
           ub.place.obj-code = pobj-code and
           ub.place.pl-code = ppl-code   no-error.
if not available ub.place then do:
  return error
  ("объект " + pobj-type + string(pobj-code) + chr(10) +
   "резервуар " + string(ppl-code) + chr(32) + "не найден").
end.
v-is-petrol-place = yes.
run trg/plloc1wv.p (
                     input pobj-type
                    ,input pobj-code
                    ,input ppl-code
                    ,input ub.place.loc1
                    ,input ub.place.is-meas
                    ,input-output v-is-petrol-place
                    ,output v-ok) no-error.
if error-status:error or
   v-ok <> yes        then do:
  return error return-value.
end.
_creation:
do on error undo _creation, return error return-value:
  assign
    varstatus = 'тек':U.
  for each  ub.pl-pump no-lock where
            ub.pl-pump.obj-type = pobj-type and
            ub.pl-pump.obj-code = pobj-code and
            ub.pl-pump.pl-code  = ppl-code  on error undo, return error return-value :
    find first bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type  = ub.pl-pump.obj-type  and
                                       bf_pl-pump-nozzle.obj-code  = ub.pl-pump.obj-code  and
                                       bf_pl-pump-nozzle.pl-code   = ub.pl-pump.pl-code   and
                                       bf_pl-pump-nozzle.pump-code = ub.pl-pump.pump-code no-lock no-error.
    for each other-pl-gds-pump no-lock where
             other-pl-gds-pump.obj-type  = pobj-type            and
             other-pl-gds-pump.obj-code  = pobj-code            and
             other-pl-gds-pump.pump-code = ub.pl-pump.pump-code and
             other-pl-gds-pump.gds-code  = pgds-code            on error undo, return error return-value :
      if other-pl-gds-pump.pl-code <> ppl-code then do:
        find first bf-other_pl-pump-nozzle where bf-other_pl-pump-nozzle.obj-type  = other-pl-gds-pump.obj-type  and
                                                 bf-other_pl-pump-nozzle.obj-code  = other-pl-gds-pump.obj-code  and
                                                 bf-other_pl-pump-nozzle.pl-code   = other-pl-gds-pump.pl-code   and
                                                 bf-other_pl-pump-nozzle.pump-code = other-pl-gds-pump.pump-code no-lock no-error.
        if available bf_pl-pump-nozzle       and
           available bf-other_pl-pump-nozzle and
           bf_pl-pump-nozzle.nozzle-code <> bf-other_pl-pump-nozzle.nozzle-code then do:
              undo _creation, return error
               ("объект " + pobj-type + string(pobj-code) + chr(10) +
                "ТРК " + string(ub.pl-pump.pump-code) + " наливает топливо c внутренним кодом " + string(pgds-code) +
                " из резервуара " + string(other-pl-gds-pump.pl-code) + " через пистолет " + string(bf-other_pl-pump-nozzle.nozzle-code) +
                " . А данный резервур " + string(ub.pl-pump.pl-code) + " наливает на этой ТРК через пистолет " + string (bf_pl-pump-nozzle.nozzle-code) + ".Это недопустимо.").
         end.
         else do:
              if other-pl-gds-pump.status_ = 'тек':U and nzpl-spl (input other-pl-gds-pump.obj-type, input other-pl-gds-pump.obj-code) then do:
                message "На ТРК "  string(ub.pl-pump.pump-code)  " наливает топливо с внутренним кодом "  string(pgds-code)
                        " из резервуара " string(other-pl-gds-pump.pl-code) "."
                        "Данная привязка получит статус блокированный."
                view-as alert-box.
                assign
                  varstatus = 'блок':U.
              end.
         end.
      end.
    end.
    create ub.pl-gds-pump.
    assign
      ub.pl-gds-pump.obj-type  = pobj-type
      ub.pl-gds-pump.obj-code  = pobj-code
      ub.pl-gds-pump.pl-code   = ppl-code
      ub.pl-gds-pump.gds-code  = pgds-code
      ub.pl-gds-pump.pump-code = ub.pl-pump.pump-code
      ub.pl-gds-pump.status_   = varstatus
      .
    run cplgdspm in this-procedure (input ub.pl-gds-pump.obj-type ,
                                    input ub.pl-gds-pump.obj-code ,
                                    input ub.pl-gds-pump.pl-code  ,
                                    input ub.pl-gds-pump.gds-code ,
                                    input ub.pl-gds-pump.pump-code,
                                    input ub.pl-gds-pump.status_     )
    no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
  create ub.pl-gds.
  assign
    ub.pl-gds.obj-type = pobj-type
    ub.pl-gds.obj-code = pobj-code
    ub.pl-gds.pl-code  = ppl-code
    ub.pl-gds.gds-code = pgds-code
    ub.pl-gds.status_  = 'тек':U
  .
end.
assign
 parresult = yes
.
