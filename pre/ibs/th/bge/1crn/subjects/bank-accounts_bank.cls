USING Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.bank-accounts from propath.
using ibs.th.bge.1crn.subjects.bank-accounts_bank from propath.
block-level on error undo, throw.
CLASS ibs.th.bge.1crn.subjects.bank-accounts_bank inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property bank-name   as character    no-undo get.
    private set.
  define property bik         as character    no-undo get.
    private set.
  define property bank-city   as character    no-undo get.
    private set.
  define property cor-acc     as character    no-undo get.
    private set.
  define property qr-rule     as integer      no-undo get.
    private set.
  define property bank-deposit-debit as character    no-undo get.
    private set.
  define property bank-deposit-kredit as character    no-undo get.
    private set.
  define override property InitTag as character no-undo init "bank"
    get.
  method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "bank-name" then
        do:
          assign
            bank-name = inValue .
        end.
      when "bik" then
        do:
          assign
            bik = inValue .
        end.
      when "bank-city" then
        do:
          assign
            bank-city = inValue .
        end.
      when "cor-acc" then
        do:
          assign
            cor-acc = inValue .
        end.
      when "qr-rule" then
        do:
          assign
            qr-rule = integer(inValue) .
        end.
      when "bank-deposit-debit" then
        do:
          assign
            bank-deposit-debit = inValue .
        end.
      when "bank-deposit-kredit" then
        do:
          assign
            bank-deposit-kredit = inValue .
        end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = v-str + ",bik"
      when bik = ?
      v-str = v-str + ",cor-acc"
      when cor-acc = ?
      .
    v-str = trim (v-str, ",").
    if v-str > ''
      then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      bank-name = ?
      cor-acc   = ?
      bank-city = ?
      bik       = ?
      qr-rule   = ?
      bank-deposit-debit = ?
      bank-deposit-kredit = ?
      .
  end.
END CLASS.
