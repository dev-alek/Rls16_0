/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработчик контента атд клиента.


Автор: Морозов Александр Сергеевич
Дата создания: 08/05/18
Author: Alexandr Morozov
Creation date: 08/05/18

*/


using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.

&scop CRLF chr(10) + chr(13)
&scop HdEnd chr(10) + chr(13)  + chr(10) + chr(13)

class ibs.th.skt.ControlledClients.atdclient : 
  
  { cmp/str-glbl.i class}
  {str/lib-trn.i class}
  
  define private variable logWrite as class LogWrite no-undo.

  define public property SomeStr as longchar no-undo /* сюда писать если что-то отправить*/
    get.
    set.

  constructor public atdclient (  ):
   
    logWrite = new LogWrite().
       
  end.
  
  method public void hndler (req as class ibs.th.skt.Commands.IRequest):
    define variable vExp as class ibs.th.bge.atd.dict-atd-exp no-undo.
    define variable mbuffer-out as character no-undo.
    define variable vLC as longchar no-undo.
    define variable v-cont-length as integer no-undo.
    define buffer bclients    for ub.clients.

    find first bclients where bclients.obj-type = 'маг'
                          and bclients.db-num   = ibs.th.gbl.gbl-var:g#db-num
                          and bclients.stts     = 0 
    no-lock no-error.
    if available bclients then do:
       vExp = new ibs.th.bge.atd.dict-atd-exp(bclients.db-num,
                                              bclients.obj-type,
                                              bclients.obj-code).
   
       LogWrite:LogStr = substitute("Обработка &1:&2:&3:&4:&5",
                                    "atdclient",
                                    req:QueryPar,
                                    bclients.db-num,
                                    bclients.obj-type,
                                    bclients.obj-code).
       
      req:Content.
      case req:HeadHTTP:QueryPar:
        when "GetObj"       
        then 
          vLC = vExp:GetNObjectTable().
        when "GetCashDesk"  
        then 
          vLC = vExp:GetNCassaTable().
        when "GetFuel"      
        then 
          vLC = vExp:GetReCodesTable().
        when "GetTank"      
        then 
          vLC = vExp:GetNTankTable().
        when "GetSched"      
        then 
          vLC = vExp:GetNSchedTable().
        otherwise 
        vLC = "".
      end case.
      delete object vExp.
      SomeStr = vLC.
    end. 
  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public atdclient ( ):
      delete object logWrite.
	end destructor.
  
  
end class.
  
