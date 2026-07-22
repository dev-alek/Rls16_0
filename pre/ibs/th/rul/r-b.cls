block-level on error undo, throw.
class Ibs.Th.Rul.R-b:
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-b.cls $":U .
define variable vss-archive     as character no-undo init "$Archive: ibs/th/rul/r-b.cls $":U .
define variable vss-description as character no-undo init "Класс r-b".
  define public property R-b as character no-undo
  get.
  set( input p-R-b as character ):
    if p-R-b <> 'rubl':U
    and p-R-b <> 'base':U then do:
      return error substitute("Неверное значение R-b &1", p-R-b).
    end.
    assign
    R-b = p-R-b.
  end set.
  CONSTRUCTOR PUBLIC R-b(  input g#language as character  ):
    if g#language <> "rus" then do:
      message
      vss-workfile vss-revision vss-description skip
      'incorrect language':U skip
      'str-glbl:':U 'rus':U skip
      'db:':U g#language skip
      view-as alert-box error.
      undo, return error .
    end.
    assign
    R-b = 'rubl':U.
  END CONSTRUCTOR.
  method public override character ToString ():
     return R-b.
  end method.
  method public character select-value ( input p-title as character):
    define variable v-ok as logical no-undo.
    define variable v-r-b as character no-undo .
    run ref/s-R-b.w ( input p-title
                     ,input-output v-R-b
                     ,output v-ok) no-error.
    if v-ok = yes then do:
      R-b = v-R-b.
    end.
  end method.
end class.
