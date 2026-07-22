block-level on error undo, throw.
class utl.math:
   method public static logical lxor(
      input iA as logical,
      input iB as logical):
      return (iA and not iB)
          or (iB and not iA).
   end method.
   method private static char cxor(
      input iA as char,
      input iB as char):
      def var vA  as int64 no-undo.
      def var vI  as int64 no-undo.
      def var vC1 as int64 no-undo.
      def var vC2 as int64 no-undo.
      assign
         vC1 = asc(iA)
         vC2 = asc(iB)
      .
      do vI  = 1 to 8:
         put-bits(vA,vI,1) = if lxor(get-bits(asc(iA),vI,1) = 1,
                                     get-bits(asc(iB),vI,1) = 1) then 1 else 0.
      end.
      return chr(vA).
   end method.
   method public static int64 ixor(
      input iA as int64,
      input iB as int64):
      def var vA  as int64 no-undo.
      def var vI  as int64 no-undo.
      do vI  = 1 to 64:
         put-bits(vA,vI,1) = if utl.math:lxor(get-bits(iA,vI,1) = 1,
                                              get-bits(iB,vI,1) = 1) then 1
                                                                     else 0.
      end.
      return vA.
   end method.
   method public static char xcode(
      input iPass as char,
      input iKey  as char):
      def var vI   as int64 no-undo.
      def var vRes as char no-undo init "".
      def var vP   as int64 no-undo.
      def var vK   as int64 no-undo.
      do vI = 1 to length(iPass):
         assign
            vP = vI mod LENGTH(iPass)
            vK = vI mod LENGTH(iKey)
         .
         if vP = 0 then vP = length(iPass).
         if vK = 0 then vK = length(iKey).
         vRes = vRes + cxor(substring(iPass,vP,1),substring(iKey,vK,1)).
      end.
      return vRes.
   end method.
end class.
