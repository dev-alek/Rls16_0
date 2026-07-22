using Progress.Lang.*.
using ibs.th.str.utd.sts.*.
using ibs.th.str.marking.sts.*.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impmsgs:
    define public property vss-revision    as character no-undo init "$Revision:$":U get .
    define public property vss-author      as character no-undo init "$Author:$":U get.
    define public property vss-date        as character no-undo init "$Date:$":U get.
    define public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define public property vss-archive     as character no-undo init "$Archive:$":U get.
    define public property vss-description as character no-undo init "Статусы электронных документов" get.
  define static private temp-table msgs no-undo
     field msg as character
     field sec as character
     field err as character
  .
  constructor static impmsgs (  ):
  end constructor.
  method public static void writeMsg( iMsg as character, iErr as character ):
      create msgs.
      assign
        msgs.msg = iMsg
        msgs.err = iErr
      .
  end method.
  method public static void writeSec( iSec as character ):
      for each msgs where msgs.sec = "":
        msgs.sec = iSec.
      end.
  end method.
  method public static void clearMsg():
      empty temp-table msgs.
  end method.
  method public static void writeError2Db(
    iEsysId as integer,
    iDbNum as integer,
    iCrDbNum as integer,
    iPackNum as integer
    ):
    define variable vCount as integer no-undo.
    define buffer esys-pck-rcvd-err for ub.esys-pck-rcvd-err.
    for each msgs:
      create esys-pck-rcvd-err.
      assign
        vCount = vCount + 1
        esys-pck-rcvd-err.esys-id        = iEsysId
        esys-pck-rcvd-err.db-num         = iDbNum
        esys-pck-rcvd-err.espr-cr-db-num = iCrDbNum
        esys-pck-rcvd-err.espr-pack-num  = iPackNum
        esys-pck-rcvd-err.num            = vCount
        esys-pck-rcvd-err.msg            = msgs.msg
        esys-pck-rcvd-err.section        = msgs.sec
        esys-pck-rcvd-err.error          = msgs.err
      .
    end.
  end method.
end class.
