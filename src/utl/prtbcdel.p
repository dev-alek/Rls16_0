block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prtbcdel.p $
$Archive: utl/prtbcdel.p $

Обработка удаления неиспользуемых бар-кодов на признаки и партии

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/03
Author: Bakhtadze Natalya
Creation date: 10/31/03

*/

define input parameter p-node-code as logical no-undo .
define input parameter p-part-code as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prtbcdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prtbcdel.p $":U .
define variable vss-description as character no-undo init "Обработка удаления неиспользуемых бар-кодов на признаки и партии".
{ cmp/vssrevis.i }

define buffer buf_goods  for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.

{ cmp/gds-list.i gds-list def shared }
{ cmp/trg-def.i  }
{ nws/db-rec.i   }
{ gbl/key-rec.i  }
{ gbl/waitfram.i }
{ trg/prtbcdel.i }

define variable v-ii as integer no-undo .
define variable v-is as logical no-undo .
define variable v-ext-prg-handle as handle    no-undo .
define variable l-is-used as logical no-undo .
define variable v-is-remote-dbs as logical no-undo .

if not p-node-code and not p-part-code then do:
  message
  "Не определено какие неиспользуемые бар-коды удалять" skip
  "(бар-коды признаков И/ИЛИ бар-коды партий)"
  view-as alert-box error .
  return  .
end.
do
on error undo, return error
:

  if not can-find(first ub.db no-lock where ub.db.db-num > 0) then do:
    run value( "trg/bar-codt.p":U ) persistent set v-ext-prg-handle .
  end.
  else do:
    assign
    v-is-remote-dbs = yes
    .
  end.

  _gds-list:
  for each gds-list no-lock,
      first buf_goods no-lock where
          buf_goods.gds-code = gds-list.gds-code:
    assign
    v-ii = v-ii + 1
    .
    run waitfram-show in this-procedure ("Ждите" + {&space-char} + "обработано" + {&space-char} + string(v-ii) ).
    if not p-part-code then do:
      /*проверим что это шкальный товар*/
      find first buf_gds-prt no-lock where
                buf_gds-prt.upper-code = buf_goods.prt-root no-error .
      if not avail buf_gds-prt then do:
        NEXT _gds-list.
      end.
      if buf_gds-prt.node-name = {&empty-scale} then NEXT _gds-list.
    end.
    run process-goods in this-procedure (input buf_goods.gds-code) no-error .
    if error-status:error then do:
      next _gds-list.
    end.
  END. /*for each gds-list*/
  if v-is-remote-dbs = no then
  delete procedure v-ext-prg-handle .
  run waitfram-hide in this-procedure .
end. /*doe*/

procedure process-goods :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
  _main:
  do
  on error undo _main, return error
  :
    define variable v-main-b-code like ub.bar-code.b-code no-undo .
    define variable v-key-rec as character no-undo .
    define variable v-param          as character no-undo .
    define buffer buf_bar-code for ub.bar-code.

    { gbl/gdsbcode.i p-gds-code ? v-main-b-code }

     _buf_bar-code:
     for each buf_bar-code where
              buf_bar-code.gds-code = p-gds-code
     on error undo _main, return error
                :
       if buf_bar-code.b-code = v-main-b-code then NEXT _buf_bar-code.
       if not p-node-code
       and buf_bar-code.in-code = "":U then NEXT _buf_bar-code.

       if v-is-remote-dbs then do:
          run gen-key-rec( input {&table_bar-code}
                          ,input (buffer buf_bar-code:handle )
                          ,output v-key-rec
                        ) no-error.
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при генерации уникального ключа для бар-кода" skip
              substitute( "товар &1", buf_bar-code.gds-code ) skip
              substitute( "бар-код &1", buf_bar-code.b-code ) skip
              substitute( "код признака &1", buf_bar-code.node-code ) skip
              substitute( "код партии &1", buf_bar-code.part-code ) skip
              substitute( "код ПН &1", buf_bar-code.in-code ) skip
              substitute( "ед.изм. &1", buf_bar-code.unit-cli ) skip
              return-value
              view-as alert-box error .
            undo _main, return error.
          end.
          assign
          v-param = string(buf_bar-code.b-code) + {&delim-par}  +
                    string(buf_bar-code.gds-code) + {&delim-par} +
                    string(buf_bar-code.node-code) + {&delim-par} +
                    buf_bar-code.part-code + {&delim-par} +
                    buf_bar-code.in-code + {&delim-par} +
                    buf_bar-code.unit-cli + {&delim-par} +
                    string(buf_bar-code.cli-base-rate)
          .
          if p-node-code then do:
            assign
            v-is = no
            .
            run is-prt-bar-code in this-procedure (
                                                    input buf_bar-code.b-code
                                                    ,input buf_bar-code.node-code
                                                    ,input buf_bar-code.part-code
                                                    ,input buf_bar-code.in-code
                                                    ,input buf_bar-code.unit-cli
                                                    ,output v-is) no-error .
            if not error-status:error and
            v-is then do:
              run nws/db-rec.p ( input {&delete_nu-prt-bar-code}
                            ,input v-key-rec
                            ,input v-param
                          ) no-error .
            end.
            else do:
              if not p-part-code then  NEXT _buf_bar-code.
            end.
          end.
          if p-part-code then do:
            assign
            v-is = no
            .
            run is-part-bar-code in this-procedure (
                                                    input buf_bar-code.b-code
                                                    ,input buf_bar-code.node-code
                                                    ,input buf_bar-code.part-code
                                                    ,input buf_bar-code.in-code
                                                    ,input buf_bar-code.unit-cli
                                                    , output v-is) no-error .
            if not error-status:error and
            v-is then do:
              run nws/db-rec.p ( input {&delete_nu-part-bar-code}
                            ,input v-key-rec
                            ,input v-param
                          ) no-error .
            end.
            else do:
              NEXT _buf_bar-code.
            end.
          end.
        end. /*для системы с удаленками        */
        else do:
          if p-node-code then do:
            assign
            v-is = no
            .
            run is-prt-bar-code in this-procedure (
                                                    input buf_bar-code.b-code
                                                    ,input buf_bar-code.node-code
                                                    ,input buf_bar-code.part-code
                                                    ,input buf_bar-code.in-code
                                                    ,input buf_bar-code.unit-cli
                                                    ,output v-is) no-error .
            if not error-status:error
            and v-is  then do:
              run value( "proc-is-used-prt-bar-code" ) in v-ext-prg-handle (buffer buf_bar-code, input g#db-num, input ?, output l-is-used) no-error .
              if not error-status:error
              and not l-is-used then do:
                delete buf_bar-code.
              end.
              else do:
                if not p-part-code then  NEXT _buf_bar-code.
              end.
            end.
          end.
          if p-part-code then do:
            assign
            v-is = no
            .
            run is-part-bar-code in this-procedure (
                                                    input buf_bar-code.b-code
                                                    ,input buf_bar-code.node-code
                                                    ,input buf_bar-code.part-code
                                                    ,input buf_bar-code.in-code
                                                    ,input buf_bar-code.unit-cli
                                                    , output v-is) no-error .
            if not error-status:error and
            v-is then do:
              run value( "proc-is-used-part-bar-code" ) in v-ext-prg-handle (buffer buf_bar-code, input g#db-num, output l-is-used) no-error .
              if not error-status:error
              and not l-is-used then do:
                delete buf_bar-code.
              end.
              else do:
                NEXT _buf_bar-code.
              end.
            end.
          end.
        end.

        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении неиспользуемого бар-кода" skip
            substitute( "товар &1", buf_bar-code.gds-code ) skip
            substitute( "бар-код &1", buf_bar-code.b-code ) skip
            substitute( "код признака &1", buf_bar-code.node-code ) skip
            substitute( "код партии &1", buf_bar-code.part-code ) skip
            substitute( "код ПН &1", buf_bar-code.in-code ) skip
            substitute( "ед.изм. &1", buf_bar-code.unit-cli ) skip
            return-value skip
            error-status :get-message(1)
            view-as alert-box error .
          undo _main, return error.
        end.
     end.
  end.

end procedure. /* process-goods */