/*

$Revision: 96e5dfe574dc, 846, rls $
$Author: ASMorozov $
$Date: Fri Oct 14 14:13:25 2016 +0300 $
$Workfile: alctypeattr.cls $
$Archive: ibs/th/ref/alctypeattr.cls $

Библиотека методов для работы с атрибутами видов алкогольной продукции

Автор: Морозов Александр Сергеевич
Дата создания: 10/09/16
Author: Alexandr Morozov
Creation date: 10/09/16

*/

using ibs.th.ref.*.
block-level on error undo, throw.

class ibs.th.ref.AlcTypeAttr :

  define variable ii as integer no-undo.

  method public void GetAlcTypeAttr (input  p-alc-type-code as character, input p-code as character, output p-value as decimal):

    define buffer buf_alc-type-attr for ub.alc-type-attr . 
    do
      on error undo, return error
      :
    
      find first ub.alc-type where ub.alc-type.alc-type-code = p-alc-type-code no-error. 
          
      if available (ub.alc-type)
        then 
      do:
        find first buf_alc-type-attr no-lock where
          buf_alc-type-attr.alc-type-inner-code         = ub.alc-type.alc-type-inner-code
          and   buf_alc-type-attr.create-user-db-num    = ub.alc-type.create-user-db-num
          and   buf_alc-type-attr.attr-code             = p-code no-error .
        
        if not available buf_alc-type-attr then 
        do:
          return error return-value
            .
        end.
        else 
        do:
          assign
            p-value = decimal (buf_alc-type-attr.attr-value)
        no-error.
        end.
      
      end.
      
    end.
    
    release buf_alc-type-attr.

  end method.

end class.