using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.
class ibs.th.str.marking.Types inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Типы маркировки" get.
  define public property  tabak      as class propmap no-undo get.  protected set.
  define public property  shoes      as class propmap no-undo get.  protected set.
  define public property  perfume    as class propmap no-undo get.  protected set.
  define public property  industry   as class propmap no-undo get.  protected set.
  define public property  tires      as class propmap no-undo get.  protected set.
  define public property  apteka     as class propmap no-undo get.  protected set.
  define public property  photo      as class propmap no-undo get.  protected set.
  define public property  milk       as class propmap no-undo get.  protected set.
  define public property  water      as class propmap no-undo get.  protected set.
  define public property  stiki      as class propmap no-undo get.  protected set.
  define public property  milk-40    as class propmap no-undo get.  protected set.
  define public property  NSJ        as class propmap no-undo get.  protected set.
  define public property  Bad        as class propmap no-undo get.  protected set.
  define public property  antiseptic as class propmap no-undo get.  protected set.
  define public property  Badd2L7    as class propmap no-undo get.  protected set.
  constructor public Types ():
    define buffer code for ub.code.
    define variable vCode as integer no-undo.
    super().
    assign
       tabak = Unknow
       shoes = Unknow
       perfume = Unknow
       industry = Unknow
       tires = Unknow
       apteka = Unknow
       photo = Unknow
       milk = Unknow
       water = Unknow
       stiki = Unknow
       milk-40 = Unknow
       NSJ = Unknow
       Bad = Unknow
       antiseptic = Unknow
       Badd2L7 = Unknow
    .
    for each code no-lock where code.parent = "MarkType":
        vCode = int(code.code) no-error.
        if vCode <> ? then
        do:
            if vCode = 1 then
              tabak = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 2 then
              shoes = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 3 then
              perfume = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 4 then
              industry = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 5 then
              tires = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 6 then
              apteka = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 7 then
              photo = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 8 then
              milk = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 9 then
              water = crProp(vCode,code.codevalue,code.codename).
           else if vCode = 10 then
              stiki = crProp(vCode,code.codevalue,code.codename).
           else if vCode = 11 then
              milk-40 = crProp(vCode,code.codevalue,code.codename).
           else if vCode = 12 then
              NSJ = crProp(vCode,code.codevalue,code.codename).
          else if vCode = 13 then
              Bad = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 14 then
              antiseptic = crProp(vCode,code.codevalue,code.codename).
            else if vCode = 16 then
              Badd2L7 = crProp(vCode,code.codevalue,code.codename).
            else
              crProp(vCode,code.codevalue,code.codename).
        end.
    end.
    Unknow:Label_  = "Неизвестный тип маркировки.".
  end.
end class.
