/*------------------------------------------------------------------------
    File        : exp-clients_kontur.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Tue Aug 11 12:05:42 MSK 2015
    Notes       :
  ----------------------------------------------------------------------*/
  
using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw. 
  
define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-clients_kontur.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/exp-clients_kontur.p $":U .
define variable vss-description as character no-undo init "Экспорт информации о структуре Фирм/объектов в Контур.EDI".

/* ***************************  Definitions  ************************** */


define input parameter parparentproc as widget-handle no-undo .
define parameter buffer X_ext-system for ub.ext-system .


DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_ext-classif FOR ub.ext-classif.
DEFINE BUFFER XX_ext-classif FOR ub.ext-classif.

define buffer buf_firm for ub.firm .
define buffer buf_clients for ub.clients .
define buffer buf_sysconf for ub.sysconf .

define variable v-uniq-key-rec as character no-undo .
define variable v-err as logical no-undo .
define variable v-custom-pack-name as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-obj-gln as character no-undo .
define variable v-sender-gln as character no-undo .
define variable v-recipient-gln as character no-undo .
define variable v-frm-gln as character no-undo .
define variable v-type as character no-undo .
define variable v-head-code as integer no-undo .
define variable v-mess as character no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-EDIINTERCHANGEID as character no-undo .
define variable v-error as character no-undo .
define variable sw as handle no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable p-cmd-code as integer no-undo initial 0.
define variable p-cmd-proc-handle as handle no-undo .

define variable ExpData1 as class Route-data_ no-undo .
/*&scop constructor_1 ( input parparentproc, input this-procedure:handle, input this-procedure:handle, input this-procedure:handle)*/
&scop constructor_1 ( input parparentproc, input this-procedure:handle, input this-procedure:handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

define variable v-DATA as memptr no-undo.

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command-ext }
 { rul/context_f.i  set-custom-esys-pck-name }
 { rul/context_f.i  delete-command }
 
 { cmp/trg-def.i  }
 { ref/extclass.i }
 { bge/esysattr.i }
 { rul/garbcoll.i }
 &glob cmd-proc-handle p-cmd-proc-handle
 &glob cmd-code p-cmd-code
 { gbl/gate-clb.i }
 { cus/str-edi.i  }


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

_main:
do
on error undo _main, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
    IF  context_begin-esys-command( input string(X_ext-system.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    
    run ext-system-attr-value in this-procedure ( input X_ext-system.esys-id
                                                 ,input X_ext-system.db-num
                                                 ,input {&attr-esys-gln-net}
                                                 ,output v-sender-gln
                                                 ,output v-type) no-error.
    run ext-system-attr-value in this-procedure ( input X_ext-system.esys-id
                                                 ,input X_ext-system.db-num
                                                 ,input {&attr-esys-gln-provider}
                                                 ,output v-recipient-gln
                                                 ,output v-type) no-error.                       
    
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("memptr", v-DATA).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("eDIMessage") .
    sw:insert-attribute ("id", ("PARTIN_" + replace((string(today) + string(time)), "/", ""))) .
        sw:start-element ("interchangeHeader") .
            sw:write-data-element ("sender", v-sender-gln) .
            sw:write-data-element ("recipient", v-recipient-gln) .
            sw:write-data-element ("documentType", "PARTIN") .
/*            sw:write-data-element ("isTest", "1") .*/
            sw:write-data-element ("creationDateTime", substring(iso-date(NOW), 1, 23) + "Z")  .
        sw:end-element ("interchangeHeader") .
        sw:start-element ("partyInformation") .
        sw:insert-attribute ("number", replace((string(today) + string(time)), "/", "")) .
        sw:insert-attribute ("date", string(iso-date(TODAY))) .
            sw:start-element ("headGLN") .
                sw:write-data-element ("gln", v-sender-gln) .
/*                find first buf_firm no-lock where buf_firm.firm-code = X_clients.obj-code no-error .*/
/*                if available buf_firm then do :                                                     */
/*                    sw:start-element ("organization") .                                             */
/*                        sw:write-data-element ("name", X_clients.obj-name) .                        */
/*                        sw:write-data-element ("inn", buf_firm.inn) .                               */
/*                        sw:write-data-element ("kpp", buf_firm.kpp) .                               */
/*                    sw:end-element ("organization") .                                               */
/*                end.                                                                                */
            sw:end-element ("headGLN") .
            sw:start-element ("parties") .

    for each buf_sysconf no-lock,
       first X_ext-classif no-lock
       where X_ext-classif.classif-subject = {&table_clients}
         and X_ext-classif.classif-name = {&extclass_clients_exite-edi}
         and X_ext-classif.db-num = - 1
         and X_ext-classif.key#_one = X_ext-system.esys-id
         and ENTRY(2, X_eXt-classif.uniq-key-rec, {&delim-key}) = {&cmp}
         and integer(ENTRY(3, X_eXt-classif.uniq-key-rec, {&delim-key})) = buf_sysconf.host-code
    :
        v-frm-gln = get-gln( input {&cmp}
                            ,input buf_sysconf.host-code) no-error.
        find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = buf_sysconf.host-code .                   
                sw:start-element ("invoicee") .
                    sw:write-data-element ("gln", v-frm-gln) .  
                    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
                    if available buf_firm then do :
                        sw:start-element ("organization") .
                            sw:write-data-element ("name", buf_clients.obj-name) .
                            sw:write-data-element ("inn", buf_firm.inn) .
                            sw:write-data-element ("kpp", buf_firm.kpp) .
                        sw:end-element ("organization") .
                    end.
                sw:end-element ("invoicee") . 
                
        for each X_clients no-lock
           where X_clients.host-code = buf_sysconf.host-code
           ,
           first XX_ext-classif no-lock
           where XX_ext-classif.classif-subject = {&table_clients}
             and XX_ext-classif.classif-name = {&extclass_clients_exite-edi}
             and XX_ext-classif.db-num = - 1
             and XX_ext-classif.key#_one = X_ext-system.esys-id
             and ENTRY(2, XX_eXt-classif.uniq-key-rec, {&delim-key}) = X_clients.obj-type
             and integer(ENTRY(3, XX_eXt-classif.uniq-key-rec, {&delim-key})) = X_clients.obj-code
        :
            v-obj-gln = get-gln( input X_clients.obj-type
                            ,input X_clients.obj-code) no-error.                
                sw:start-element ("deliveryParty") .
                    sw:write-data-element ("gln", v-obj-gln) .  
                    find first buf_firm no-lock where buf_firm.firm-code = X_clients.host-code no-error .
                    if available buf_firm then do :
                        sw:start-element ("organization") .
                            sw:write-data-element ("name", X_clients.obj-name) .
                            sw:write-data-element ("inn", buf_firm.inn) .
                            sw:write-data-element ("kpp", buf_firm.kpp) .
                        sw:end-element ("organization") .
                    end.
                    
                    sw:start-element ("additionalInfo") . 
                        sw:write-data-element ("parentGLN", v-frm-gln) .
                    sw:end-element ("additionalInfo") .
                                                                  
                sw:end-element ("deliveryParty") .                     
        end.
    end.    
            sw:end-element ("parties") . 
        sw:end-element ("partyInformation") . 
    sw:end-element ("eDIMessage") .
    sw:end-document () .
    delete object sw.
    
    IF ExpData1:esys-add-dump-data ( INPUT v-DATA, INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        undo _main, return error v-last-error-message .
    end.

    /* формируем пакет */
    IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-dump-ord-int64 = context_send-esys-command( input string(X_ext-system.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid).
    if v-dump-ord-int64 = 0 THEN do:
      undo _main, return error v-last-error-message .
    end.

    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .          

end.
