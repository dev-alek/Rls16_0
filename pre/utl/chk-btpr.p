block-level on error undo, throw.
define input  parameter p-type-cut as integer   no-undo .
define input  parameter p-db-list  as character no-undo .
define output parameter p-ready    as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 784232a2254b, 2720, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн янв 18 10:14:30 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-btpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chk-btpr.p $":U .
define variable vss-description as character no-undo init "проверка BatchProcess ДО начала обрезания".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_BatchProcess for ub.BatchProcess .
  define variable v-return-value as character no-undo .
  assign
    p-ready        = true
    v-return-value = "":U
  .
  for each buf_BatchProcess
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    case buf_BatchProcess.BP_type
    :
      when 'autonws':U or
      when 'autoarh':U or
      when 'autoexp':U or
      when 'autooxml':U or
      when 'autosuz':U or
      when 'autogcd':U or
      when 'autosale':U or
      when 'autocbnk':U or
      when 'autofree':U or
      when 'mercury':U or
      when 'hddtest':U or
      when 'is_motp':U or
      when 'is_diadoc':U or
      when 'is_PM':U
      then do:
      end.
      when 'cutdbs':U
      then do:
      end.
      when 'rt-doc':U or
      when 'rt-line':U or
      when 'bcprint':U
      then do:
      end.
      when 'lkrt':U
      then do:
        assign
          p-ready = false
          v-return-value = v-return-value + chr(10)
                           + substitute( "Маршрутизация в БД &1 заблокирована пользователем &2 &3 в &4 (&5)"
                                         ,buf_BatchProcess.CharKey_One
                                         ,buf_BatchProcess.User_ID
                                         ,string( buf_BatchProcess.BP_SysDate, "99.99.9999" )
                                         ,buf_BatchProcess.BP_SysTime
                                         ,buf_BatchProcess.CharKey_Three
                                        )
        .
      end.
      when 'autoupg':U
      then do:
        assign
          p-ready = false
          v-return-value = v-return-value + chr(10) + "Не завершен upgrade."
        .
      end.
      when 'arh':U
      then do:
      end.
      when 'ahsp':U
      then do:
      end.
      when 'aht':U
      then do:
      end.
      when 'prc':U
      then do:
      end.
      when 'trnhd':U
      then do:
      end.
      when 'hold':U
      then do:
      end.
      when 'hinv':U
      then do:
      end.
      when 'hspi':U
      then do:
      end.
      when 'gds':U
      then do:
      end.
      when 'dcard':U
      then do:
      end.
      when 'goa':U
      then do:
      end.
      when 'slr':U
      then do:
      end.
      when 'cshr':U
      then do:
      end.
      when 'fgrp':U
      then do:
      end.
      when 'mvob':U
      then do:
          assign
          p-ready = false
          v-return-value = v-return-value + chr(10) +
                          substitute("Не завершен перенос объекта из одной БД в БД:&1" +
                                     "&2&3 переносится из БД &4 в БД &5"
                                     , chr(10)
                                     , buf_BatchProcess.CharKey_One
                                     , buf_BatchProcess.Key#_One
                                     , buf_BatchProcess.Key#_Two
                                     , buf_BatchProcess.Key#_Three )
          .
      end.
      when 'bcode':U
      then do:
      end.
      when 'rnar':U
      then do:
      end.
      otherwise do:
        if buf_BatchProcess.BP_type begins 'lock':U
        or buf_BatchProcess.BP_type begins 'lusr':U
        then do:
        end.
        else do:
          return error substitute("&1. Неизвестный тип BatchProcess &2", vss-workfile, buf_BatchProcess.BP_type ) .
        end.
      end.
    end case.
  end.
  return v-return-value .
end.
