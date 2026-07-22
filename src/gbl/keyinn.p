block-level on error undo, throw.
/*

$Revision: cb1b05444cdf, 212, rls $
$Author: EShklyar $
$Date: Tue Jun 30 11:12:07 2015 +0400 $
$Workfile: keyinn.p $
$Archive: gbl/keyinn.p $

Проверка ИНН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/13/03
Author: Bakhtadze Natalya
Creation date: 11/13/03

*/

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
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

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
  when {&cmp} then do:
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

  when {&prs} then do:
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
          return substitute("{&abbr_inn_allshift} &1: Неверная длина {&abbr_inn_allshift} - &2 - должна быть буква <F> и/или 10 цифр"
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
          return substitute("{&abbr_inn_allshift} &1: Неверные символы в {&abbr_inn_allshift}"
                            , p-inn).
        end.
        assign
        p-correct = (string(v-int) = substring(left-trim(p-inn, "F":U), 10, 1)
                    )
        .
        if p-correct then return "":U.
        else return substitute("{&abbr_inn_allshift} &1: Неверное значение {&abbr_inn_allshift}", p-inn).
      end.
      when "12":U then do:
        if length(p-inn) <> 12 then do:
          return substitute("{&abbr_inn_allshift} &1: Неверная длина {&abbr_inn_allshift} - &2 - должна быть 12 цифр"
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
          return substitute("{&abbr_inn_allshift} &1: Неверные символы в {&abbr_inn_allshift}"
                             , p-inn).
        end.
        /*
        assign
        p-inn = substring(p-inn, 1, 10) + string(v-int)
        .
        */
        if string(v-int) <> substring(p-inn, 11, 1) then do:
          return substitute("{&abbr_inn_allshift} &1: Неверное значение {&abbr_inn_allshift}", p-inn).
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
          return substitute("{&abbr_inn_allshift} &1: Неверные символы в {&abbr_inn_allshift}", p-inn).
        end.
        assign
        p-correct = (string(v-int) = substring(p-inn, 12, 1))
        .
        if p-correct then return "":U.
        else return substitute("{&abbr_inn_allshift} &1: Неверное значение {&abbr_inn_allshift}", p-inn).
      end. /*when 12*/
    END CASE.
  end.

end procedure. /* check12 */