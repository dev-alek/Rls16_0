using Progress.Lang.*.
using ibs.th.gbl.collection.paramCol from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.export.send1cerp
   inherits   ibs.th.gbl.sys.objth
   implements ibs.th.rul.route_date_error
:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка в 1С" get.
   define public property parparentproc as handle    no-undo
   get. set.
   define public property parent-handle as handle    no-undo get. set.
   define public property log-handle    as handle    no-undo get. set.
   define public property processType   as character no-undo get. set.
   define public property oldbh         as handle    no-undo get. set.
   define public property newbh         as handle    no-undo get. set.
   define public property params        as paramCol  no-undo get. set.
   define public property classExport   as character no-undo get. set.
   define variable cmd-code      as character no-undo.
   define variable m-DATA        as memptr no-undo.
   define property Msg as character no-undo
   get.
   private set.
method public logical context_begin-esys-command
(
    input p-esys-id-list as character
   ,input-output p-esys-cmd-proc-handle as handle
   ,output p-esys-cmd-code as integer
):
   if not valid-handle(p-esys-cmd-proc-handle )
   then do:
     run nws/cmd-bush.p persistent set p-esys-cmd-proc-handle no-error .
     if error-status :error
     then do:
        setError ( substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                           "&5&4&6"
                                           ,vss-workfile
                                           ,vss-revision
                                           ,vss-description
                                           ,chr(10)
                                           ,error-status:get-message(1)
                                           ,return-value )).
     end.
     run begin-create-command in p-esys-cmd-proc-handle
       (input 'cmd-esys-general':U
       ,input p-esys-id-list
       ,output p-esys-cmd-code
       ) no-error.
     if error-status :error
     then do:
       setError ( input substitute("Ошибка при создании команды &1&2&3&1&4"
                                                        , 'cmd-esys-general':U
                                                        , error-status:get-message(1)
                                                        , return-value
                                                        )).
       return no .
     end.
     return yes.
   end.
end.
method public int64 context_send-esys-command
(
    input p-esys-id-list as character
   ,input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
   ,input p-user-id as character
):
   define variable v-dmp-ord-int64 as int64 no-undo .
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run send-command-esys in p-esys-cmd-proc-handle
          (input p-esys-cmd-code
          ,input p-esys-id-list
          ,input p-user-id
          ,output v-dmp-ord-int64
          ) no-error.
      if error-status :error
      then do:
         setError ( input substitute("Ошибка при отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                        , p-esys-id-list
                                                        , cmd-code
                                                        , chr(10)
                                                        , error-status:get-message(1)
                                                        , return-value
                                                        )).
         return 0.
      end.
      delete procedure p-esys-cmd-proc-handle no-error.
      return v-dmp-ord-int64.
   end.
   else do:
      setError ( input substitute("Ошибка при отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                    , p-esys-id-list
                                                    , cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return 0 .
   end.
end.
method public logical context_set-custom-esys-pck-name
(
    input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
   ,input p-custom-pck-name as character
):
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run set-custom-esys-pck-name in p-esys-cmd-proc-handle (
                                                              input p-esys-cmd-code
                                                             ,input p-custom-pck-name) no-error .
      if error-status :error
      then do:
         setError ( input substitute("Ошибка при установке спец имени пакета для отсылки во внешнюю систему команды с кодом &1&2&3&2&4"
                                                     , cmd-code
                                                     , chr(10)
                                                     , error-status:get-message(1)
                                                     , return-value
                                                     )).
         return no .
      end.
      return yes.
   end.
   else do:
      setError ( input substitute("Ошибка при установке спец имени пакета для отсылки во внешнюю систему команды с кодом &1&2&3&2&4"
                                                    , cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return no .
   end.
end.
   method public void setError(iText as char):
      msg = iText.
      if valid-handle (log-handle)        then          run write-log-and-file in log-handle (                   input 1                                          , input "send1cerp.log"                             , input 1                                          , input Msg) no-error.
   end.
   constructor public send1cerp (input  i-parparentproc   as handle,
                                 input  i-parent-handle   as handle,
                                 input  i-log-handle      as handle,
                                 input  i-process         as character,
                                 input  i-oldbh           as handle,
                                 input  i-newbh           as handle,
                                 input  i-param           as paramCol
   ):
      super ().
      assign
         parparentproc = i-parparentproc
         parent-handle = i-parent-handle
         log-handle    = i-log-handle
         processType   = i-process
         oldbh         = i-oldbh
         newbh         = i-newbh
         params        = i-param
      .
      init().
      if Msg = ""
      then
         exportData().
   end constructor.
   destructor public send1cerp ( ):
   end destructor.
   method private void init ():
      cmd-code = "cmd-send-&1-to-1C-ERP".
      msg = "".
      if     classExport ne ?
         and classExport ne ""
      then
         .
      else if     processType ne ?
         and processType ne ""
      then do:
         classExport = substitute ("ibs.th.bge.1crn.subjects.exp-&1", processType).
      end.
      else if newbh:available
      then do:
         cmd-code = substitute (cmd-code, newbh:table).
         classExport = substitute ("ibs.th.bge.1crn.subjects.exp-obj-&1", newbh:table).
      end.
      else if oldbh:available
      then do:
         cmd-code = substitute (cmd-code, oldbh:table).
         classExport = substitute ("ibs.th.bge.1crn.subjects.exp-obj-&1", oldbh:table).
      end.
      if    classExport eq ?
         or classExport eq ""
      then do:
          setError("Не передана команда и буфер для отправки.").
      end.
      else if    search(replace(classExport,".","/") + ".r"  ) eq ?
         and search(replace(classExport,".","/") + ".cls") eq ?
      then do:
         setError(substitute ("Не найден класс экспорта &1",replace(classExport,".","/") + ".r")).
      end.
   end.
   method public logical exportData():
      define variable ExpData as class Ibs.Th.Rul.Route-data_ no-undo .
ExpData = new Ibs.Th.Rul.Route-data_ (this-object,parparentproc,parent-handle,log-handle).
ObjSrv:Regobj(this-object,ExpData,
"ExpData"
) .
      exportData(ExpData) no-error .
      if error-status:error then
      do:
         setError(substitute("&1 &2&3",return-value,error-status:get-message(1))).
      end.
      finally:
         if valid-object (ExpData)
         then
            delete object ExpData.
      end finally.
   end.
   method private void exportData(input ExpData as class Ibs.Th.Rul.Route-data_) :
      if not valid-object (ExpData)
      then do:
         setError("Объект ExpData должен быть создан").
         return.
      end.
      define variable subOBj as class ibs.th.bge.1crn.export.send1cerpsub no-undo .
      _main:
      do
      on error undo, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), MSG)
      :
         if retry then do:
            setError(substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), MSG)).
            return.
         end.
         subOBj = dynamic-new classExport() no-error.
         if error-status:error
         then do:
            setError(substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), MSG)).
            return.
         end.
         ObjSrv:RegObj(this-object,subOBj).
         define variable v-custom-pack-name   as character   no-undo .
         define variable v-dump-ord-int64     as int64       no-undo .
         define buffer buf_sys-ctrl   for sys-ctrl.
         define buffer buf_ext-system  for ub.ext-system.
         define variable expObj as class ibs.th.bge.1crn.export.expsubject no-undo .
         ObjSrv:RegObj(this-object,subOBj).
         define variable v-esys-id-list as character no-undo.
         define variable v-esys-cmd-proc-handle as handle no-undo.
         define variable v-esys-cmd-code as int no-undo.
         find first buf_sys-ctrl no-lock .
         v-esys-id-list = "" .
         for each buf_ext-system no-lock where buf_ext-system.delivery-method = integer('11':U)
                                           and buf_ext-system.esys-have-export = yes
                                          and buf_ext-system.esys-db-num-exp = buf_sys-ctrl.db-num :
            v-esys-id-list = v-esys-id-list + string(buf_ext-system.esys-id) + chr(1) .
         end.
         v-esys-id-list = trim(v-esys-id-list, chr(1)) .
         if v-esys-id-list = ""
         then do :
            setError ( "Нет внешней системы с методом доставки 1C-RN." ) .
            return.
         end.
         subObj:setContext(parparentproc,
                      parent-handle,
                      log-handle,
                      processType,
                      oldbh,
                      newbh,
                      params) no-error.
         if error-status:error
         then do:
            Msg = subObj:msg.
            undo _main, return .
         end.
         if  context_begin-esys-command( input v-esys-id-list, input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false
         then do:
            undo _main, retry .
         end.
         expObj = new ibs.th.bge.1crn.export.expsubject ().
         expObj:GetContent(subObj) no-error.
         if error-status:error
         then do:
            Msg = expObj:msg.
            undo _main, retry .
         end.
         if ExpData:esys-add-dump-data ( input expObj:Data,
                                         input v-esys-cmd-proc-handle,
                                         input v-esys-cmd-code,
                                        ('+update' + chr(4) + expObj:InitSecTag) +
                                         (if expObj:sendTableName <> ""
                                          then substitute("&1&2&3&4",chr(4),
                                                          expObj:sendTableName,
                                                          if expObj:sendOldRowid <> ? then substitute("&1&2",chr(3),expObj:sendOldRowid) else "",
                                                          if expObj:sendNewRowid <> ? then substitute("&1&2",chr(3),expObj:sendNewRowid) else "")
                                          else "")) = false
         then do:
            undo _main, retry .
         end.
         if  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false
         then
            undo _main, retry .
         v-dump-ord-int64 = context_send-esys-command( input v-esys-id-list
                                                     , input v-esys-cmd-proc-handle
                                                     , input v-esys-cmd-code
                                                     , input ibs.th.gbl.gbl-var:g#userid).
         if v-dump-ord-int64 = 0
         then
            undo _main, retry .
         ExpData:Route-data_clear-data ( ) .
         finally:
            if valid-object (subObj)
            then
               delete object subObj.
            if valid-handle (v-esys-cmd-proc-handle)
            then
               delete procedure v-esys-cmd-proc-handle no-error.
         end finally.
      end.
   end.
end class.
