/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 7 янв. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 7 янв. 2023 г.

*/

using Progress.Lang.*.
using ibs.th.gbl.collection.paramCol from propath.

block-level on error undo, throw.

class ibs.th.bge.1crn.export.send1cerp 
   inherits   ibs.th.gbl.sys.objth
   implements ibs.th.rul.route_date_error
:
&glob globobjSrv yes /* он уже объявлен в ibs.th.gbl.sys.objth */
{ cmp/str-glbl.i class}
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка в 1С" get.
 

&Scop putError setError(substitute("&1 &2&3",return-value,error-status:get-message(1))).  
&Scop log-file send1cerp.log
&scop display-message ~
        if valid-handle (log-handle)~
        then~
          run write-log-and-file in log-handle (   ~
                input 1                            ~
              , input "~{&log-file}"               ~
              , input 1                            ~
              , input Msg) no-error.
 
   
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
/*   define variable keyRec as class ibs.th.gbl.keyrec no-undo.*/
   
   &glob cmd-code cmd-code
   { bge/sendesys.i  begin-esys-command }
   { bge/sendesys.i  send-esys-command-ext }
   { bge/sendesys.i  set-custom-esys-pck-name }
   
   method public void setError(iText as char):
      msg = iText.
      {&display-message}
      
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
      { utl/objreg.i ExpData Ibs.Th.Rul.Route-data_ this-object parparentproc parent-handle log-handle}
      exportData(ExpData) no-error .
      if error-status:error then 
      do:
         {&putError}
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
      on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), MSG)
      :
         if retry then do:
            setError(substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), MSG)).
            return.
         end.
         subOBj = dynamic-new classExport() no-error.
         if error-status:error
         then do:
            setError(substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), MSG)).
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
         for each buf_ext-system no-lock where buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
                                           and buf_ext-system.esys-have-export = yes
                                          and buf_ext-system.esys-db-num-exp = buf_sys-ctrl.db-num :
            v-esys-id-list = v-esys-id-list + string(buf_ext-system.esys-id) + {&delim-nws} .                               
         end.                                    
         v-esys-id-list = trim(v-esys-id-list, {&delim-nws}) .                                  
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
                                        ('+update' + {&delim-par} + expObj:InitSecTag) + 
                                         (if expObj:sendTableName <> "" 
                                          then substitute("&1&2&3&4",{&delim-par},
                                                          expObj:sendTableName,
                                                          if expObj:sendOldRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendOldRowid) else "",
                                                          if expObj:sendNewRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendNewRowid) else "") 
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
      end. /*doe _main*/
   end. /* proc-main */
end class.
