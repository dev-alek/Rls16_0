block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматическое создание контрольной сверки
АВТОМАТИЧЕСКИЙ ОПРОС ТРК ОТКЛЮЧЕН, ТАК КАК КОЛОНКИ ВСТАЮТ ЕСЛИ ОПРОС ИДЕТ ВО ВРЕМЯ НАЛИВА

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/06
Author: Dmitry Ukhanov
Creation date: 11/29/06

Автор1: Булгаков Андрей Николаевич
Дата создания1: 11/28/05

*/

define input parameter parparentproc   as widget-handle no-undo.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-rvs-code  as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Автоматическое создание контрольной сверки":U.
DEFINE VARIABLE mParam AS CHARACTER NO-UNDO.
DEFINE VARIABLE mRVSNull AS LOGICAL no-undo init no.
publish "RVSParam" (output mParam).

mRVSNull = logical (entry(1,mParam)) no-error.
if mRVSNull eq ? then mRVSNull = no.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/libbcrcn.i }
{ str/lib-rvs.i  }
{ adm/auto-def.i }
{ ref/shd-attr.i }
{ cmp/ini-lib.i  }
{ str/doc-code.i }
{ str/trdcalib.i }
{ str/rvsttdef.i }
{ gbl/getsect.i def }
{ str/placelib.i }
{ gbl/ptrlprop.i def }
{ ref/gds-attr.i }
{ gbl/db-attr.i }

define variable v-ret-msg   as character no-undo.

define variable v-obj-type  as character no-undo.
define variable v-obj-code  as integer   no-undo.
define variable v-obj-date  as date      no-undo.
define variable v-host-code as integer   no-undo.
define variable g#log       as logical   no-undo.

define variable v-rvs-code    as character no-undo.
define variable v-is-ptrl     as character no-undo.
define variable v-data-type   as character no-undo.

define variable v-obj-list    as character no-undo.
define variable v-curr-obj    as character no-undo.
define variable jj            as integer   no-undo.
define variable v-ok          as logical      no-undo.

define variable varcur-data   as integer   no-undo.

define buffer buf_icnt-doc      for ub.icnt-doc.
define buffer buf_rvs-doc       for ub.rvs-doc.
define buffer buf_rvs-line      for ub.rvs-line.
define buffer buf_rvs-line-pump for ub.rvs-line-pump .
define buffer cur_shift-obj     for ub.shift-obj.
define buffer prev_shift-obj    for ub.shift-obj.
define buffer prev_rvs-doc      for ub.rvs-doc.
define buffer prev_icnt-doc     for ub.icnt-doc.
define buffer buf_clients       for ub.clients .
define buffer buf_doc-attr      for ub.doc-attr .
define variable v-full as logical no-undo.
define variable v-wrkr    as integer no-undo .
define variable v-agnt    as integer no-undo .
define variable v-boss    as integer no-undo .

define variable v-asi-ip  as character no-undo .
define variable v-asi-port as character no-undo .
define variable v-asi-type as character no-undo .
define variable v-attr-type as character no-undo .

define temp-table obj-list no-undo
  field obj-type  as character
  field obj-code  as integer
  field host-code as integer
  field db-num    as integer
  index pi        is primary   unique obj-type obj-code.

Main-Block:
do
on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:

  { gbl/conf-rd.i
    "'is-ptrl'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-is-ptrl
    v-data-type
    no-error
  }
  if error-status :error
    or v-data-type <> "L"
    or v-is-ptrl <> "yes"
  then do:
    undo Main-Block, return 'Нет учета топлива в системе.' .
  end.



  find first buf_clients no-lock
    where buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code
    no-error .
  if not available buf_clients then do:
    run add-msg in this-procedure
      ( input true
      , input substitute( 'Неизвестный объект &1 &2 в списке секции [revision] ini-файла.', v-obj-type, v-obj-code )
      ) .
  end.

  if g#db-num <> buf_clients.db-num then do:
    run add-msg in this-procedure
      ( input true
      , input substitute( 'Объект &1 &2 не из текущей БД (&3).', v-obj-type, v-obj-code, g#db-num )
      ) .
  end.

  create obj-list.
  assign
    obj-list.obj-type  = buf_clients.obj-type
    obj-list.obj-code  = buf_clients.obj-code
    obj-list.host-code = buf_clients.host-code
    obj-list.db-num    = g#db-num
  .


  block_obj:
  for first obj-list no-lock
  on error undo block_obj, retry block_obj
  :
    if retry then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( "&1 (block_obj). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        ) .
      next block_obj .
    end.

    assign
      v-obj-type  = obj-list.obj-type
      v-obj-code  = obj-list.obj-code
      v-host-code = obj-list.host-code
    .

    find first buf_icnt-doc no-lock
      where buf_icnt-doc.obj-type  = v-obj-type
        and buf_icnt-doc.obj-code  = v-obj-code
        and buf_icnt-doc.doc-type  = {&icnt-doc}
        and buf_icnt-doc.status_  <> {&fact}
      no-error .
    if available buf_icnt-doc then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'На объекте &1 &2 имеется не закрытый документ инвентаризации счетчиков ТРК "&3".', v-obj-type, v-obj-code, buf_icnt-doc.doc-code )
        ) .
      undo block_obj, next block_obj .
    end.
 
    find first cur_shift-obj no-lock
      where cur_shift-obj.obj-type = v-obj-type
        and cur_shift-obj.obj-code = v-obj-code
        and cur_shift-obj.status_  = {&sht-current}
      no-error .
    if not available cur_shift-obj then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'На объекте &1 &2 нет открытой смены.', v-obj-type, v-obj-code )
        ) .
      undo block_obj, next block_obj .
    end.

    find last prev_shift-obj no-lock
      where prev_shift-obj.obj-type   = cur_shift-obj.obj-type
        and prev_shift-obj.obj-code   = cur_shift-obj.obj-code
        and prev_shift-obj.status_    = {&sht-closed}
        and ( prev_shift-obj.shift-date < cur_shift-obj.shift-date
              or prev_shift-obj.shift-date = cur_shift-obj.shift-date
                 and prev_shift-obj.shift-num  < cur_shift-obj.shift-num
            ) use-index stts
      no-error .
    if available prev_shift-obj then do:
      find last prev_rvs-doc no-lock
        where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
          and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
          and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
          and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
          and prev_rvs-doc.status_    = {&fact}
          and prev_rvs-doc.rvs-type   = {&rvs-shift}
        no-error .
    end.
    find last prev_icnt-doc no-lock
      where prev_icnt-doc.obj-type = v-obj-type
        and prev_icnt-doc.obj-code = v-obj-code
        and prev_icnt-doc.doc-type  = {&icnt-doc}
        and prev_icnt-doc.status_  = {&fact}
        use-index fact-order
      no-error .

    { gbl/ptrlprop.i run v-obj-type v-obj-code }
    { gbl/getsect.i run v-obj-type v-obj-code {&attr-autosale} }
    
    
    for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-autosale_wrkr} then assign v-wrkr = thbjattr_thbj-attr.property-value-integer .
      if thbjattr_thbj-attr.prop-code = {&attr-autosale_agnt} then assign v-agnt = thbjattr_thbj-attr.property-value-integer .
      if thbjattr_thbj-attr.prop-code = {&attr-autosale_boss} then assign v-boss = thbjattr_thbj-attr.property-value-integer .
      
    end.
    
        { gbl/getsect.i run v-obj-type v-obj-code {&attr-petrol} }
  for each thbjattr_thbj-attr :    
        if thbjattr_thbj-attr.prop-code = {&attr-petrol_autopump-izm} then assign v-full = thbjattr_thbj-attr.property-value-logical .
end.


    assign
      v-wrkr  = (if v-wrkr = 0 then ? else v-wrkr)
      v-agnt  = (if v-agnt = 0 then ? else v-agnt)
      v-boss  = (if v-boss = 0 then ? else v-boss)
    .
    /* добавление документа */
    run doc-code in this-procedure
      (  input 'main':U
      ,  input v-obj-type
      ,  input v-obj-code
      ,  input ?
      , output v-rvs-code
      ) no-error .
    if error-status :error then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка при генерации номера документа для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) .
      undo block_obj, next block_obj .
    end.

    { gbl/curobjdt.i 
      v-obj-type
      v-obj-code
      v-obj-date
    }

    create buf_rvs-doc.
    assign
      buf_rvs-doc.rvs-code  = v-rvs-code
      buf_rvs-doc.host-code = v-host-code
      buf_rvs-doc.obj-type  = v-obj-type
      buf_rvs-doc.obj-code  = v-obj-code
      buf_rvs-doc.status_   = {&g___new}
      buf_rvs-doc.rvs-type  = {&rvs-control}
      buf_rvs-doc.out-code  = ?
      buf_rvs-doc.creid     = g#userid
      buf_rvs-doc.ps        = '@':U
      buf_rvs-doc.doc-date  = v-obj-date
      buf_rvs-doc.wrkr      = v-wrkr
      buf_rvs-doc.agnt      = v-agnt
      buf_rvs-doc.boss      = v-boss
      buf_rvs-doc.is-full = v-full
/*      buf_rvs-doc.whole-send-news = 1*/
    .
    run gbl/factdate.p
      ( input        buf_rvs-doc.obj-type
      , input        buf_rvs-doc.obj-code
      , input-output buf_rvs-doc.fact-date
      , input-output buf_rvs-doc.fact-time
      , input-output buf_rvs-doc.shift-date
      , input-output buf_rvs-doc.shift-num
      , input-output buf_rvs-doc.shift-name
      , input        no
      ) no-error .
    if error-status :error then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка при установке даты в документе rvs-doc (factdate.p) для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) .
      undo block_obj, next block_obj .
    end.

    /* прописывание оборота по документам в атрибуты */
    run str/rvs-attr.p
      ( input buf_rvs-doc.rvs-code
      , input buf_rvs-doc.obj-type
      , input buf_rvs-doc.obj-code
      , output v-ok
                    ) no-error.
    if error-status :error
      or v-ok = false
    then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка подсчета остатков для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) . 
    end.

    create buf_doc-attr.
    assign
      buf_doc-attr.doc-code = buf_rvs-doc.rvs-code
      buf_doc-attr.attr-code = "rvs-auto"
      buf_doc-attr.attr-value = "Yes"
    .
    
      { str/place-sh.i
      buf_rvs-doc.obj-type
      buf_rvs-doc.obj-code
      buf_rvs-doc.rvs-code
      buf_rvs-doc.rvs-type
      "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
      cur_shift-obj.shift-date
      cur_shift-obj.shift-num
      buf_rvs-doc.is-full
      no-error
    }
    
    if error-status :error then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка при создании строк документа сверки для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) .
      undo block_obj, next block_obj .
    end.

    { str/meas-plc.i
      buf_rvs-doc.obj-type
      buf_rvs-doc.obj-code
      tt-meas
      no-error
    }
    if error-status :error then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка при определении измеряемых резервуаров для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) .
      undo block_obj, next block_obj .
    end.
    if not mRVSNull 
    then do:
        find first tt-meas no-error .
        
        if     available tt-meas
         
        then do:
    
          find first sys-ctrl no-lock.
	      run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
	      run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
	      run db-attr-value(sys-ctrl.db,"AsiType",output v-asi-type,output v-attr-type).
	      if trim(v-asi-ip) <> ''
	      and trim(v-asi-port) <> ''
	      and trim(v-asi-type) <> ''
	      then do :
	        case v-asi-type :
	          when "1"
	          then do :
	            varcur-data = 2 .
	          end.
	          when "2"
	          then do :
	            varcur-data = 3 .
	          end.
	        end case .
	      end.
	      else do :
            varcur-data = 1 .
          end.
          { str/rvsplace.i
            buf_rvs-doc.obj-type
            buf_rvs-doc.obj-code
            ?
            varcur-data
            false
            no
            tt-meas-file
            tt-meas
            no-error
          }
          if error-status :error then do:
            run add-msg in this-procedure
              ( input true
              , input substitute( 'Ошибка при получении данных с приборов на резервуарах для объекта &1 &2 .&3&4&3&5'
                                  , v-obj-type
                                  , v-obj-code
                                  , {&new-line}
                                  , error-status :get-message( 1 )
                                  , return-value
                                )
              ) .
            undo block_obj, next block_obj .
          end.
        end.
        { str/fall-plc.i
          buf_rvs-doc.obj-type
          buf_rvs-doc.obj-code
          buf_rvs-doc.rvs-code
          ?
          no-error
        }
        if error-status :error then do:
          run add-msg in this-procedure
            ( input true
            , input substitute( 'Ошибка при сохранении данных с приборов на резервуарах для объекта &1 &2 .&3&4&3&5'
                                , v-obj-type
                                , v-obj-code
                                , {&new-line}
                , error-status :get-message( 1 )
                , return-value
                )
                ) .
            undo block_obj, next block_obj .
        end.
    end.    
    else do:
        define variable v-value as character no-undo.
        define variable vType as character no-undo.
        define variable v-min-dens as decimal no-undo.
        for each buf_rvs-line exclusive-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
        and buf_rvs-line.obj-code = buf_rvs-doc.obj-code:
            run placelib_get-attr  ( input {&place-dens-prov}
                ,input buf_rvs-line.obj-code
                ,input buf_rvs-line.obj-type
                ,input buf_rvs-line.pl-code
                ,output v-value
                ,output v-ok      ) no-error. 
                buf_rvs-line.state-measure-qnty = 0.01.  
                buf_rvs-line.state-density = dec(v-value).
            if    buf_rvs-line.state-density eq 0
               or buf_rvs-line.state-density eq ?
            then do:
                run gds-attr-value in this-procedure
                    ( input  buf_rvs-line.gds-code
                     ,input  {&attr-gds-ptrl-densities}
                     ,output v-value
                     ,output vtype) .
                if v-value <> "" and v-value <> ? then 
                do:
                   assign
                      v-min-dens = decimal(replace(entry(1, v-value, "-":U ), "кг\л", "":U))
                      buf_rvs-line.state-density = v-min-dens
                      // v-max-dens = decimal(replace(entry(2, v-value, "-":U ), "кг\л":U, "":U))
                      no-error.
                end.
            end.
            if    buf_rvs-line.state-density eq 0
               or buf_rvs-line.state-density eq ?
            then
               buf_rvs-line.state-density = 0.75.
          
         end.
            
    end. 

    if ptrlprop-autopump = true then do:
      { str/pump-sh.i
        buf_rvs-doc.obj-type
        buf_rvs-doc.obj-code
        buf_rvs-doc.rvs-code
        buf_rvs-doc.rvs-type
        "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
        "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
        cur_shift-obj.shift-date
        cur_shift-obj.shift-num
        yes
        no
        no-error
      }
      if error-status :error then do:
        run add-msg in this-procedure
          ( input true
          , input substitute( 'Ошибка при создании строк ТРК документа сверки для объекта &1 &2 .&3&4&3&5'
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , error-status :get-message( 1 )
                              , return-value
                            )
          ) .
/*        undo block_obj, next block_obj .*/
      end.

      { str/measpmnz.i
        buf_rvs-doc.obj-type
        buf_rvs-doc.obj-code
        tt-pump-nozzle
        no-error
      }
      if error-status :error then do:
        run add-msg in this-procedure
          ( input true
          , input substitute( 'Ошибка при определении измеряемых пистолетов ТРК для объекта &1 &2 .&3&4&3&5'
                              , v-obj-type
                              , v-obj-code
                              , {&new-line}
                              , error-status :get-message( 1 )
                              , return-value
                            )
          ) .
/*        undo block_obj, next block_obj .*/
      end.

      find first tt-pump-nozzle no-error .
      if     can-find( first tt-pump-nozzle )
         and not mRVSNull      
      then do:
        /* varcur-data = true - при автоматическом создании всегда читаем текущие данные */
        { str/rvs-pump.i
          parparentproc
          buf_rvs-doc.obj-type
          buf_rvs-doc.obj-code
          buf_rvs-doc.rvs-code
          true
          tt-pump-nozzle-file
          tt-pump-nozzle
          no-error
        }
        if error-status :error 
          or return-value <> "":U
        then do:
          run add-msg in this-procedure
            ( input true
            , input substitute( 'Ошибка при получении данных с приборов на ТРК для объекта &1 &2 .&3&4&3&5'
                                , v-obj-type
                                , v-obj-code
                                , {&new-line}
                                , error-status :get-message( 1 )
                                , return-value
                              )
            ) .
/*          undo block_obj, next block_obj .*/
        end.
      end.
    end.
     
    for each buf_rvs-line exclusive-lock
      where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
        and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
    on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if ptrlprop-autopump = true then do:
        for each buf_rvs-line-pump exclusive-lock
          where buf_rvs-line-pump.rvs-code    = buf_rvs-line.rvs-code
            and buf_rvs-line-pump.obj-type    = buf_rvs-line.obj-type
            and buf_rvs-line-pump.obj-code    = buf_rvs-line.obj-code
            and buf_rvs-line-pump.pl-code     = buf_rvs-line.pl-code
            and buf_rvs-line-pump.gds-code    = buf_rvs-line.gds-code
        on error undo Main-Block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        :
          if buf_rvs-line-pump.meas-am-cnt = ?
            or buf_rvs-line-pump.meas-cf-cnt = ?
            or buf_rvs-line-pump.meas-el-cnt = ?
            or buf_rvs-line-pump.meas-mh-cnt = ?
          then do:
            delete buf_rvs-line-pump .
          end.
          else do:
            if buf_rvs-line-pump.state-el-cnt = ?
              or buf_rvs-line-pump.state-mh-cnt = ?
            then do:
              assign
                buf_rvs-line-pump.state-el-cnt = buf_rvs-line-pump.meas-el-cnt
                buf_rvs-line-pump.state-mh-cnt = buf_rvs-line-pump.meas-mh-cnt
              .
            end.
          end.
        end. /* for each buf_rvs-line-pump */
      end.
      if buf_rvs-line.state-measure-qnty = ?
        or buf_rvs-line.state-density = ?
        or buf_rvs-line.state-density = 0.00
      then do:
        delete buf_rvs-line .
      end.
    end. /* for each buf_rvs-line */

    find first buf_rvs-line no-lock
      where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
        and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
        and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
      no-error .
    if not available buf_rvs-line then do:
      /* В документе нет строк - удаляется. */
      delete buf_rvs-doc.
      run add-msg in this-procedure
        ( input false
        , input substitute( 'Для объекта &1 &2 сверка не создана, т.к. нет данных с приборов.'
                            , v-obj-type
                            , v-obj-code
                          )
        ) .
      undo block_obj, next block_obj .
    end.

    /* проставим rvs-doc.is-full */
    { str/rvs-full.i
      buf_rvs-doc.rvs-code
    }

    { str/rvsclchd.i
      "recid( buf_rvs-doc )"
      yes
      no-error
    }
    if error-status :error then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка при пересчете шапки документа сверки для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) .
      undo block_obj, next block_obj .
    end.

    /* закрытие документа до статуса {&permitted} */
    { str/rvsclose.i
      parparentproc
      "recid( buf_rvs-doc )"
      no
      no-error
    }
    if error-status :error then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка при закрытии документа сверки для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) .
      undo block_obj, next block_obj .
    end.

    /* закрытие документа на факт */
    { str/rvsclose.i
      parparentproc
      "recid( buf_rvs-doc )"
      no
      no-error
    }
    if error-status :error then do:
      run add-msg in this-procedure
        ( input true
        , input substitute( 'Ошибка при закрытии документа сверки для объекта &1 &2 .&3&4&3&5'
                            , v-obj-type
                            , v-obj-code
                            , {&new-line}
                            , error-status :get-message( 1 )
                            , return-value
                          )
        ) .
      undo block_obj, next block_obj .
    end.

    run add-msg in this-procedure
      ( input false
      , input substitute( 'Создана контрольная сверка N &1 для объекта &2 &3 . '
                          , buf_rvs-doc.rvs-code
                          , v-obj-type
                          , v-obj-code
                        )
      ) .
      
    p-rvs-code = buf_rvs-doc.rvs-code .

  end. /* for each obj-list */



  return v-ret-msg .

end. /* Main-Block */

procedure add-msg :

  define input parameter p-err as logical   no-undo .
  define input parameter p-msg as character no-undo .

  do
  on error  undo, return error substitute( "&1 (add-msg). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (add-msg). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (add-msg). endkey", vss-workfile )
  :
    if v-ret-msg <> "":U then do:
      assign
        v-ret-msg = v-ret-msg + {&new-line}
      .
    end.
    if p-err = true then do:
      assign
        v-ret-msg = v-ret-msg + substitute( "ОШИБКА! &2", p-msg )
      .
    end.

    assign
      v-ret-msg = v-ret-msg + p-msg
    .

  end.

end procedure. /* add-msg */