using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impsettings inherits ibs.th.gbl.sys.objth implements ibs.th.bge.1crn.import.iimpsubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Импорт setting" get.
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
  // thbjattr_thbj-attr
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable mImp2CdH as handle no-undo.
    define variable objSettings as class     ibs.th.bge.1crn.subjects.settings no-undo.
    define variable vMaxApiToken as character no-undo init "" .
    define variable v-mem as memptr no-undo .
    define variable v-file as character no-undo .
    define variable v-arh-name as character no-undo .
    define variable v-password as character no-undo init "K7#mP@9xL2$q" .
    define variable v-retfl     as logical no-undo .
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    define buffer buf_clients for ub.clients .
    objSettings = cast (subjectObj, ibs.th.bge.1crn.subjects.settings).
    if trim(objSettings:MaxApiToken) = ""
    then do :
      v-retfl = true .
      return true .
    end .
    for first buf_clients no-lock where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
                                    and buf_clients.obj-type = 'маг':U
                                    and buf_clients.stts     = 0
    :
      if buf_clients.host-code <> integer(objSettings:org-code)
      then do :
        undo, throw new Progress.Lang.AppError(
            "Некорректная привязка токена авторизации к организации."
        ) .
      end .
      assign
        v-arh-name = search( "exe/7z.exe":U )
      .
      if v-arh-name = ? then do:
        assign
          v-arh-name = search( "exe/7za.exe":U )
        .
      end.
      v-mem = base64-decode (objSettings:MaxApiToken) .
      copy-lob from v-mem to file "t_param.zip" .
      os-command silent
        value( substitute( '&1 e -y "-p&4" &2 -o&3':U, v-arh-name, search("t_param.zip"), ".\", v-password ) )
      .
      assign
        file-info:file-name = "t_param.txt"
      .
      if file-info:file-type = ?
      or not (file-info:file-type begins "F":U)
      then do :
        undo, throw new Progress.Lang.AppError(
          substitute(  "Ошибка при распаковке архива с токеном MAX. [&1 &2]",
                       error-status:get-message(1), return-value  )
        ) .
      end .
      output to t_param.txt append .
      put chr(10) .
      output close .
      input from t_param.txt .
      import unformatted vMaxApiToken .
      input close .
      os-delete value (search("t_param.zip")) .
      os-delete value (search("t_param.txt")) .
      v-tth = buffer thbjattr_thbj-attr:table-handle .
      empty temp-table thbjattr_thbj-attr .
      run adm/shattri.p (
              input "init":U
            , input 'БД':U
            , input buf_clients.db-num
            , input 'gisMT':U
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
            ) no-error .
      if error-status:error then do:
        undo, throw new Progress.Lang.AppError(
          substitute(  "Ошибка чтения начальных значений настроек работы со справочниками товаров в контексте объекта [&1 &2]",
                       error-status:get-message(1), return-value  )
        ) .
      end .
      for each thbjattr_thbj-attr:
        case thbjattr_thbj-attr.prop-code :
          when 'MaxApiToken':U then do:
            thbjattr_thbj-attr.property-value-character = vMaxApiToken .
            run str/imp2cdgeth.p(output mImp2CdH).
            run fill-setting in mImp2CdH ('thbj-attr':U,
                                          'БД':U,
                                          buf_clients.db-num,
                                          thbjattr_thbj-attr.upper-prop-code,
                                          thbjattr_thbj-attr.prop-code).
          end.
        end case .
      end .
      thbjattr_set-section ('БД':U, buf_clients.db-num, 'gisMT':U, input table thbjattr_thbj-attr) .
      v-retfl = true.
    end .
    catch exAppErrors as class Progress.Lang.AppError :
      define variable v-is-delim as logical no-undo .
      v-is-delim = (num-entries(exAppErrors:ReturnValue, chr(4)) > 1) .
      Msg = if v-is-delim then entry(2, exAppErrors:ReturnValue, chr(4)) else exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в АЗС АЗК" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      if Msg > "" then . else Msg = "ProError в АЗС АЗК" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в АЗС АЗК" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
  end method.
  method private void thbjattr_set-section (input p-obj-type   as character,
                                            input p-obj-code   as integer,
                                            input p-upper-code as character,
                                            input table-handle p-tth) :
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run thbjattr_set-section in ibs.th.gbl.gbl-hndllib:g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) .
  end method .
end class.
