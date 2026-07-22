using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.gbl-hndllib:
  define static property g#library as handle no-undo
    get.
    private set.
  define static property g#library2 as handle no-undo
    get.
    private set.
  define static property g#attr-lib as handle no-undo
    get.
    private set.
  define static property g#lib-trn as handle no-undo
    get.
    private set.
  define static property g#lib-trn2 as handle no-undo
    get.
    private set.
  define static property g#lib-trn3 as handle no-undo
    get.
    private set.
  define static property g#lib-trn4 as handle no-undo
    get.
    private set.
  define static property g#trdcalib as handle no-undo
    get.
    private set.
  define static property g#lib-rvs as handle no-undo
    get.
    private set.
  constructor static gbl-hndllib():
  end constructor.
  method public void InitHndl (
    inSubHndl as char,
    in_g#libhndl as handle
    )
    :
    case inSubHndl:
      when "g#library" then
        g#library = in_g#libhndl.
      when "g#library2" then
        g#library2 = in_g#libhndl.
      when "g#attr-lib" then
        g#attr-lib = in_g#libhndl.
      when "g#lib-trn" then
        g#lib-trn = in_g#libhndl.
      when "g#lib-trn2" then
        g#lib-trn2 = in_g#libhndl.
      when "g#lib-trn3" then
        g#lib-trn3 = in_g#libhndl.
      when "g#lib-trn4" then
        g#lib-trn4 = in_g#libhndl.
      when "g#trdcalib" then
        g#trdcalib = in_g#libhndl.
      when "g#lib-rvs" then
        g#lib-rvs = in_g#libhndl.
    end case.
  end method.
end class.
