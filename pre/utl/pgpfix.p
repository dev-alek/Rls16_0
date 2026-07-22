block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pgpfix.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pgpfix.p $":U .
define variable vss-description as character no-undo init "Утилита проверки и исправления конфигурации ТАНК-ТРК-МЕСТО".
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
define stream outstream.
define variable loc#log as logical no-undo.
message "ПРОВЕРКА (НЕТ) ИЛИ ИСПРАВЛЕНИЕ(ДА) ?" view-as alert-box QUESTION
buttons YES-NO update loc#log.
output stream outstream to pgpfix.txt.
ON WRITE OF ub.pl-gds-pump OVERRIDE DO:
end.
ON DELETE OF ub.pl-gds-pump OVERRIDE DO:
end.
FIND FIRST ub.sys-ctrl NO-LOCK.
_pl-pump:
for each ub.pl-pump no-lock,
         first ub.clients no-lock where
               ub.clients.obj-type = ub.pl-pump.obj-type AND
               ub.clients.obj-code = ub.pl-pump.obj-code AND
               ub.clients.db-num = ub.sys-ctrl.db-num:
    find ub.pl-gds-pump no-lock where
               ub.pl-gds-pump.pl-code = ub.pl-pump.pl-code AND
            ub.pl-gds-pump.pump-code = ub.pl-pump.pump-code AND
            ub.pl-gds-pump.obj-type = ub.pl-pump.obj-type AND
            ub.pl-gds-pump.obj-code = ub.pl-pump.obj-code
            NO-ERROR.
    IF AMBIGUOUS ub.pl-gds-pump then do:
        run fixa in this-procedure
            (loc#log,
            yes,
            ub.pl-pump.obj-type,
            ub.pl-pump.obj-code,
            ub.pl-pump.pl-code,
            ub.pl-pump.pump-code) no-error.
      if error-status:error then do:
        PUT stream outstream unformatted
        "Объект " ub.pl-pump.obj-type ub.pl-pump.obj-code
        " У складского места " ub.pl-pump.pl-code  "несколько связей ТОВАР-ТРК " skip
        " Не удалось исправить "
        skip.
        NEXT _pl-pump.
      end.
    end.
    find first ub.pl-gds-pump no-lock where
               ub.pl-gds-pump.pl-code = ub.pl-pump.pl-code AND
            ub.pl-gds-pump.pump-code = ub.pl-pump.pump-code AND
            ub.pl-gds-pump.obj-type = ub.pl-pump.obj-type AND
            ub.pl-gds-pump.obj-code = ub.pl-pump.obj-code
            NO-ERROR.
    if not avail ub.pl-gds-pump then do:
        run fixa in this-procedure
            (loc#log,
            no,
            ub.pl-pump.obj-type,
            ub.pl-pump.obj-code,
            ub.pl-pump.pl-code,
            ub.pl-pump.pump-code) no-error.
        if error-status:error then do:
            FIND FIRST
            ub.pl-gds No-LOCK WHERE
            ub.pl-gds.pl-code = ub.pl-pump.pl-code AND
            ub.pl-gds.obj-type = ub.pl-pump.obj-type AND
            ub.pl-gds.obj-code = ub.pl-pump.obj-code NO-ERROR.
            if avail ub.pl-gds then do:
            FIND FIRST ub.goods no-lock where
                       ub.goods.gds-code = ub.pl-gds.gds-code No-ERROR.
                PUT stream outstream unformatted
                "ub.Объект " pl-pump.obj-type ub.pl-pump.obj-code
                " Не удалось связать складское место " ub.pl-pump.pl-code
                " - ТРК " ub.pl-pump.pump-code " - ТОВАР " ub.pl-gds.gds-code " "
                ub.goods.gds-name skip skip.
            end.
            else do:
                PUT stream outstream unformatted
                "Объект " ub.pl-pump.obj-type ub.pl-pump.obj-code
                " Не удалось связать складское место " ub.pl-pump.pl-code
                " - ТРК " ub.pl-pump.pump-code " - на складском месте нет товара"
                skip skip.
            END.
        end.
    end.
end.
ON WRITE OF ub.pl-gds-pump revert.
output stream Outstream close.
message "Результаты работы утилиты ищите в файле pgpfix.txt"
view-as alert-box.
PROCEDURE fixa:
DEFINE INPUT PARAMETER paction as logical no-undo.
DEFINE INPUT PARAMETER psituation as logical no-undo.
DEFINE INPUT PARAMETER pobj-type like ub.place.obj-type no-undo.
DEFINE INPUT PARAMETER pobj-code like ub.place.obj-code no-undo.
DEFINE INPUT PARAMETER ppl-code like ub.place.pl-code no-undo.
DEFINE INPUT PARAMETER ppump-code like ub.pump.pump-code no-undo.
define buffer b-pl-gds-pump for ub.pl-gds-pump.
define buffer b-pl-gds for ub.pl-gds.
CASE psituation:
  when yes then do:
    FOR EACH b-pl-gds-pump where
             b-pl-gds-pump.obj-type = pobj-type AND
             b-pl-gds-pump.obj-type = pobj-type AND
             b-pl-gds-pump.pl-code = ppl-code AND
             b-pl-gds-pump.pump-code = ppump-code:
      FIND FIRST b-pl-gds No-LOCK WHERE
                 b-pl-gds.obj-type = pobj-type AND
                 b-pl-gds.obj-code = pobj-code AND
                 b-pl-gds.pl-code = ppl-code AND
                 b-pl-gds.gds-code = b-pl-gds-pump.gds-code No-ERROR.
      if not avail b-pl-gds then do:
        PUT stream outstream unformatted
        "Объект " pobj-type pobj-code
        " У складского места " ppl-code  "есть несколько связей ТОВАР-ТРК " skip
        " из них ТОВАР " b-pl-gds-pump.gds-code " не имеет привязки к месту " SKIP
        skip.
        if paction = yes then delete b-pl-gds-pump.
      END.
      else return error.
    END.
  end.
  when no then do:
      FIND FIRST
      ub.pl-gds No-LOCK WHERE
      ub.pl-gds.pl-code = ppl-code AND
      ub.pl-gds.obj-type = pobj-type AND
      ub.pl-gds.obj-code = pobj-code NO-ERROR.
      if not avail ub.pl-gds then return.
      error-status:error = no.
      PUT stream outstream UNFORMATTED
      "Объект " pobj-type pobj-code
      " Cкладское место " ppl-code
      " - ТРК " ppump-code " - не связано с ТОВАРОМ " skip.
      if paction = yes then do:
        DO ON ERROR UNDO, return error ON STOP undo, return error:
          create
          ub.pl-gds-pump.
          assign
          ub.pl-gds-pump.obj-type = pobj-type
          ub.pl-gds-pump.obj-code = pobj-code
          ub.pl-gds-pump.pl-code = ppl-code
          ub.pl-gds-pump.pump-code = ppump-code
          ub.pl-gds-pump.gds-code = pl-gds.gds-code
          ub.pl-gds-pump.ps = "FIXED!!!"
          ub.pl-gds-pump.status_ = 'тек':U
        .
        END.
        PUT stream outstream UNFORMATTED
        "Объект " pobj-type pobj-code
        " Cкладское место " ub.pl-pump.pl-code
        " - ТРК " ub.pl-pump.pump-code " - ТОВАР " ub.pl-gds.gds-code skip.
      end.
  end.
END CASE.
END PROCEDURE.
