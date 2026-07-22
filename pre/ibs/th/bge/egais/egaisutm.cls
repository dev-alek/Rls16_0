using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.EGAISUTM inherits EGAISImpl:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
  define protected variable TimeOut as character no-undo.
  define property ConPar as character no-undo
  get.
  protected set.
  define property VerXSD as character no-undo
  get.
  protected set.
  define property INNObj as character no-undo
  get.
  protected set.
  constructor public EGAISUTM (inOjType as char, inObjCode as int):
    define variable v-value-character   as character no-undo .
    define variable v-value-decimal     as decimal   no-undo .
    define variable v-value-integer     as integer   no-undo .
    define variable v-value-logical     as logical   no-undo .
    define variable v-value-type        as character no-undo .
    define variable v-value-date        as date      no-undo .
    get-key-value section 'EGAIS' key 'TimeOut' value TimeOut.
    if TimeOut = ? then do:
      assign
        TimeOut = "5".
    end.
    run adm/shattri.p (
         input "get":U
        ,input inOjType
        ,input inObjCode
        ,input 'egais':U
        ,input 'egais-utm':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-value-type
        ,input-output table thbjattr_thbj-attr
        ) no-error .
    ConPar = trim (v-value-character, '/').
    ConPar = trim (ConPar, '\').
    run adm/shattri.p (
         input "get":U
        ,input inOjType
        ,input inObjCode
        ,input 'egais':U
        ,input 'egais-ver-xsd':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-value-type
        ,input-output table thbjattr_thbj-attr
        ) no-error .
    if error-status:error
      then v-value-character = "1".
    case v-value-character:
      when "1" or when "" or when ? then do:
        VerXSD = "1".
      end.
      when "2" then do:
        VerXSD = "2".
      end.
      otherwise do:
        message substitute ("В настройках параметров ЕГАИС для объекта указана неверная версия схем XSD - &1. Будет использована схема по умолчанию 1", VerXSD) view-as alert-box.
        VerXSD = "1".
      end.
    end.
    run adm/shattri.p (
         input "get":U
        ,input inOjType
        ,input inObjCode
        ,input 'egais':U
        ,input 'egais-inn':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-value-type
        ,input-output table thbjattr_thbj-attr
        ) no-error .
    INNObj = v-value-character.
  end constructor.
  method protected character GetURLUTM (arg as char):
  end.
  method protected character GetSubjectOfRequestUTM ():
  end.
  method final protected logical WriteDbStatus ( inSubject as int,  inParameters as char, inReplyId as char, inSts as log ):
    define buffer buf_ext-sys for ub.ext-system.
    find first buf_ext-sys no-lock where buf_ext-sys.delivery-method = 10 no-error.
    if available (buf_ext-sys) then
    do:
      find first ub.esys-all-attr
              where ub.esys-all-attr.key7 = inReplyId no-error.
      if not available ub.esys-all-attr
        then do:
          create ub.esys-all-attr.
          ub.esys-all-attr.key4       = string (now).
        end.
      assign
        ub.esys-all-attr.table-name = "esys-pck-sent"
        ub.esys-all-attr.attr-code  = "egais"
        ub.esys-all-attr.attr-value = inParameters
        ub.esys-all-attr.key1       = buf_ext-sys.esys-id
        ub.esys-all-attr.key2       = inSubject
        ub.esys-all-attr.key3       = string (inSts)
        ub.esys-all-attr.key5       = DbNum
        ub.esys-all-attr.key7       = inReplyId
        ub.esys-all-attr.key8       = User_Id
      no-error.
      if error-status:error
      then do:
        release ub.esys-all-attr.
        return false.
      end.
    end.
    else
      return false.
    release ub.esys-all-attr.
    return true.
  end method.
  method final protected logical CheckCurrentRequest ( inSubject as int,  inParameters as char, output outReplyId as char ):
    find first ub.esys-all-attr
                where ub.esys-all-attr.table-name = "esys-pck-sent"
                and ub.esys-all-attr.attr-code = "egais"
                and ub.esys-all-attr.key2       = inSubject
                and ub.esys-all-attr.attr-value = inParameters
                and ub.esys-all-attr.key3 = string (false)
                no-error.
    if available (ub.esys-all-attr )
    then do:
      outReplyId = ub.esys-all-attr.key7.
      release ub.esys-all-attr.
      return true.
    end.
    return false.
  end method.
  method protected handle ParseResponse (inFileName as char):
  end.
  method protected void ParseResponse (inContent as char, inTableType as int):
  end.
end class.
