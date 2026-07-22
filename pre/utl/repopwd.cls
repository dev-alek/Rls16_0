using Progress.Lang.*.
using utl.*.
block-level on error undo, throw.
class utl.repoPwd inherits repository:
   define public property Obj as class tech-prol-pwd no-undo
   get.
   set.
   constructor public repoPwd (iObj as class tech-prol-pwd):
      super ().
      this-object:Obj = iObj.
   end constructor.
   method override public void Refresh(  ):
      define buffer btech-prol-pwd for ub.tech-prol-pwd.
      if Obj:Id > 0 then
      do:
         find first btech-prol-pwd where
                    btech-prol-pwd.Id = Obj:Id
         no-lock no-error.
         if avail btech-prol-pwd then
         do:
            assign
               Obj:f-date         = btech-prol-pwd.f-date
               Obj:f-time         = btech-prol-pwd.f-time
               Obj:f-user         = btech-prol-pwd.f-user
               Obj:f-host         = btech-prol-pwd.f-host
               Obj:f-pwd-type     = btech-prol-pwd.f-pwd-type
               Obj:f-pwd          = btech-prol-pwd.f-pwd
               Obj:f-fio          = btech-prol-pwd.f-fio
               Obj:f-beg-time     = btech-prol-pwd.f-beg-time
               Obj:f-end-time     = btech-prol-pwd.f-end-time
               Obj:cash-desk-surr = btech-prol-pwd.cash-desk-surr
               Obj:shop-surr      = btech-prol-pwd.shop-surr
            .
         end.
      end.
   end method.
   method override public void Save(  ):
      define buffer btech-prol-pwd for tech-prol-pwd.
      def var vId as int64 no-undo.
      tr:
      do transaction:
         vId = GetId().
         create btech-prol-pwd.
         assign
            btech-prol-pwd.id = vId
            btech-prol-pwd.f-date         = Obj:f-date
            btech-prol-pwd.f-time         = Obj:f-time
            btech-prol-pwd.f-user         = Obj:f-user
            btech-prol-pwd.f-host         = Obj:f-host
            btech-prol-pwd.f-pwd-type     = Obj:f-pwd-type
            btech-prol-pwd.f-pwd          = Obj:f-pwd
            btech-prol-pwd.f-fio          = Obj:f-fio
            btech-prol-pwd.f-beg-time     = Obj:f-beg-time
            btech-prol-pwd.f-end-time     = Obj:f-end-time
            btech-prol-pwd.cash-desk-surr = Obj:cash-desk-surr
            btech-prol-pwd.shop-surr      = Obj:shop-surr
            btech-prol-pwd.f-object-num   = INT(ENTRY(2,btech-prol-pwd.shop-surr))
            btech-prol-pwd.f-cash-num     = INT(ENTRY(4,btech-prol-pwd.cash-desk-surr))
         .
         run trg/userlog.p (
            input 'tech-prol-pwd'
          , input ("Генерация пароля " + chr(3) + string(vId) )
          , input ?
          , input ?
          , input "") no-error.
      end.
      Obj:Id = vId.
   end method.
   method private int64 GetId(  ):
      define buffer btech-prol-pwd for tech-prol-pwd.
      def var vId as int64 no-undo.
      vId = next-value(s-tech-prol-pwd).
      find first btech-prol-pwd where
                 btech-prol-pwd.id = vId
      no-lock no-error.
      cl:
      do while avail btech-prol-pwd:
         vId = next-value(s-tech-prol-pwd).
         find first btech-prol-pwd where
                    btech-prol-pwd.id = vId
         no-lock no-error.
      end.
      return vId.
   end method.
end class.
