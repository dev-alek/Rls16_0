block-level on error undo, throw.
define input parameter p-inn as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-is-pboul like ub.firm.is-pboul no-undo .
define output parameter p-correct as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: cb1b05444cdf, 212, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:12:07 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: keyinn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/keyinn.p $":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vmn0 as character no-undo init "2,4,10,3,5,9,4,6,8":U.
define variable vmn1 as character no-undo init "7,2,4,10,3,5,9,4,6,8":U.
define variable vmn2 as character no-undo init "3,7,2,4,10,3,5,9,4,6,8":U.
define variable v-int as integer no-undo .
define variable v-dop as character no-undo .
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define variable v-cor as logical no-undo .
function sum-1 returns integer(INPUT p-inn as character, input p-mnz as character, input p-ii as integer):
define variable v-sum as integer no-undo .
define variable ii as integer no-undo .
define variable v-dopi as integer no-undo .
  do ii = 1 to p-ii:
    assign
    v-dopi = integer(substring(left-trim(p-inn, "F":U), ii, 1))
    no-error .
    if error-status:error then do:
      return ?.
    end.
    assign
    v-int = v-int + v-dopi * integer(entry(ii, p-mnz))
    .
  end.
  return v-int .
END FUNCTION.
CASE p-obj-type:
  when 'орг':U then do:
    if p-is-pboul = ? then do:
      find first buf_firm no-lock where
              buf_firm.firm-code = p-obj-code no-error .
      if not avail buf_firm then do:
        return error "Неверные параметры p-obj-code и/или  p-is-pboul".
      end.
      assign
      p-is-pboul = buf_Firm.is-pboul
      .
    end.
    if p-is-pboul then do:
      run check in this-procedure ("12":U, output p-correct, output v-cor) no-error .
    end.
    else do:
      run check in this-procedure ("10":U, output p-correct, output v-cor) no-error .
      if p-correct = no and v-cor = no then do:
      run check in this-procedure ("12":U, output p-correct, output v-cor) no-error .
      end.
    end.
    if error-status:error then return error .
    return return-value.
  end.
  when 'чел':U then do:
    if p-is-pboul = ? then do:
      find first buf_person no-lock where
              buf_person.psn-code = p-obj-code no-error .
      if not avail buf_person then do:
        return error "Неверные параметры p-obj-code и/или  p-is-pboul".
      end.
      assign
      p-is-pboul = buf_person.is-pboul
      .
    end.
    run check in this-procedure ("12":U, output p-correct, output v-cor) no-error .
    if p-correct = no and v-cor = no then do:
    run check in this-procedure ("10":U, output p-correct, output v-cor) no-error .
    end.
    if error-status:error then return error .
    return return-value.
  end.
END CASE.
procedure check :
define input parameter p-par as character no-undo .
define output parameter p-correct as logical no-undo .
define output parameter p-cor as logical no-undo .
  do
  on error undo, return error
  :
    CASE p-par:
      when "10" then do:
        if length(left-trim(p-inn, "F":U)) <> 10 then do:
          assign p-cor = no.
          return substitute("ИНН &1: Неверная длина ИНН - &2 - должна быть буква <F> и/или 10 цифр"
                             ,p-inn
                             ,length (p-inn)) .
        end.
        else p-cor = yes.
        assign
        v-int = sum-1(p-inn, vmn0, 9)
        v-int = v-int MODULO 11
        v-int = v-int MODULO 10
        .
        if v-int = ? then do:
          return substitute("ИНН &1: Неверные символы в ИНН"
                            , p-inn).
        end.
        assign
        p-correct = (string(v-int) = substring(left-trim(p-inn, "F":U), 10, 1)
                    )
        .
        if p-correct then return "":U.
        else return substitute("ИНН &1: Неверное значение ИНН", p-inn).
      end.
      when "12":U then do:
        if length(p-inn) <> 12 then do:
          return substitute("ИНН &1: Неверная длина ИНН - &2 - должна быть 12 цифр"
                            , p-inn
                            , length(p-inn)).
          .
        end.
        assign
        v-int = sum-1(p-inn, vmn1, 10)
        v-int = (v-int MODULO 11)
        v-int = (v-int MODULO 10)
        .
        if v-int = ? then do:
          return substitute("ИНН &1: Неверные символы в ИНН"
                             , p-inn).
        end.
        if string(v-int) <> substring(p-inn, 11, 1) then do:
          return substitute("ИНН &1: Неверное значение ИНН", p-inn).
        end.
        assign
        v-dop = substr(p-inn, 1, 10) + string(v-int)
        v-int = 0
        v-int = sum-1(v-dop, vmn2, 11)
        .
        assign
        v-int = (v-int MODULO 11)
        v-int = (v-int MODULO 10)
        .
        if v-int = ? then do:
          return substitute("ИНН &1: Неверные символы в ИНН", p-inn).
        end.
        assign
        p-correct = (string(v-int) = substring(p-inn, 12, 1))
        .
        if p-correct then return "":U.
        else return substitute("ИНН &1: Неверное значение ИНН", p-inn).
      end.
    END CASE.
  end.
end procedure.
