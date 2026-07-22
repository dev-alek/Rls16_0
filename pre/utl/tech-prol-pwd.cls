using Progress.Lang.*.
using Utl.*.
block-level on error undo, throw.
class utl.tech-prol-pwd:
   define public property id as int64 no-undo
      get.
      set.
   define public property f-date as date no-undo
      get.
      set.
   define public property f-time as datetime no-undo
      get.
      set.
   define public property f-user as character no-undo
      get.
      set.
   define public property f-host as character no-undo
      get.
      set.
  define public property region-surr as character no-undo
      get.
      set.
   define public property shop-surr as character no-undo
      get.
      set.
   define public property cash-desk-surr as character no-undo
      get.
      set.
   define public property f-pwd-type as character no-undo
      get.
      set.
   define public property f-pwd as character no-undo
      get.
      set.
   define public property f-fio as character no-undo
      get.
      set.
   define public property f-beg-time as character no-undo
      get.
      set.
   define public property f-end-time as character no-undo
      get.
      set.
end class.
