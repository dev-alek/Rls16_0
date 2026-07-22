block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : send1C-some-data.p
    Purpose     : 

    Syntax      :

    Description : Экспорт любых данных в 1C ERP RN

    Author(s)   : SSlivenko
    Created     : 23/03/25
    Notes       :
  ----------------------------------------------------------------------*/


/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Route-data_.

/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-data as memptr no-undo .
define input parameter p-init-sec-tag as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: fc55a7295616, 2779, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Чт апр 08 19:52:17 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send1C-some-data.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send1C-some-data.p $":U .
define variable vss-description as character no-undo init "Экспорт любых данных в 1C ERP RN".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ gbl/gate-clb.i }
{ rul/rum-fn.i }
{ rul/context_f.i get-thobj-es }
{ gbl/key-rec.i }
{ bge/esysattr.i }
{ bge/tmpcxmlh.i }
{ rul/ruleset_.i }
{ cus/str-edi.i }


/*****************************/
define variable p-cmd-code as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .

define variable log-file-name as character no-undo .
define variable v-last-error-message as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-action as character no-undo .

{ str/dia2auto.i }
{ rul/seterror.i }



/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command-ext }
 { rul/context_f.i  set-custom-esys-pck-name }
 { rul/context_f.i  delete-command }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .


/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
    
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      run write-to-log in p-log-handle (substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm)) .
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

  define variable v-ii as integer no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  define variable v-datetimechar as character no-undo .
  define variable v-dump-ord-int64 as int64 no-undo .

  define buffer buf_ext-system for ub.ext-system .  
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  
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
    run write-to-log in p-log-handle ( "Нет внешней системы с методом доставки 1C-RN." ) .
    return .
  end.

  if  context_begin-esys-command( input v-esys-id-list, input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false
  then do:
    undo _main, return error v-last-error-message .
  end.

        
  if ExpData1:esys-add-dump-data ( input p-data, 
                                   input v-esys-cmd-proc-handle, 
                                   input v-esys-cmd-code, 
                                   ('+update' + {&delim-par} + entry(1,p-init-sec-tag,{&delim-par})  + 
                                    (if num-entries(p-init-sec-tag,{&delim-par}) > 1 
                                     then substitute("&1&2&3&4",
                                                     {&delim-par},
                                                     entry(2,p-init-sec-tag,{&delim-par})
                                                     ) 
                                     else "")) ) = false
  then do:
    undo _main, return error v-last-error-message .
  end.
  
  v-dump-ord-int64 = context_send-esys-command( input v-esys-id-list
                              , input v-esys-cmd-proc-handle
                              , input v-esys-cmd-code
                              , input g#userid).
  if v-dump-ord-int64 = 0
  then do:
    undo _main, return error v-last-error-message .
  end.
 


      num-rec-ok = num-rec-ok + 1.
    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
  
  
end. /*doe _main*/
end procedure. /* proc-main */
