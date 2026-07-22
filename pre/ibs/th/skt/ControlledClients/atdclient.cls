using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.atdclient :
  define private variable logWrite as class LogWrite no-undo.
  define public property SomeStr as longchar no-undo
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
        destructor public atdclient ( ):
      delete object logWrite.
        end destructor.
end class.
