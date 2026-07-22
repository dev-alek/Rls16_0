 
/*
  $Revision:$
  $Author:$
  $Date:$
  $Workfile:$
  $Archive:$
  
  Автор: Рубан Дмитрий Андреевич 
  Дата создания: 9 янв. 2023 г.
  Author:  Ruban Dmitriy Andreevich
  Creation date: 9 янв. 2023 г.
  
  */

using Progress.Lang.*.
block-level on error undo, throw.

class ibs.th.gbl.systemsetting inherits   ibs.th.gbl.sys.objth :
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Настройки разработчиков" get.
    
    
   { cmp/str-glbl.i class }  
   { GBL/xmldom.i   class }
   { cmp/library.i class }
   define public property PumpTxtRead as logical no-undo 
   get.
   private set.
    
   define public property GetCashCurl as logical no-undo 
   get.
   private set.
    
   define public property DeveloperMode as logical no-undo 
   get.
   private set.
    
   define public property CrLogin as character no-undo 
   get.
   private set.
    
   define public property CrPswd as character no-undo 
   get.
   private set.
   
   define public property SystemKey as character no-undo 
   get.
   private set.
   
   define public property PumpFile as character no-undo 
   get.
   private set.
   
   define public property AsiFile as character no-undo 
   get.
   private set.
   
   constructor public systemsetting (input ikey as character ):
      define variable vFilesetting as character no-undo.
      define variable vFound as logical no-undo.
      define variable vText as character no-undo.
      { gbl/currsysk.i
      SystemKey
      no-error
   }
 
      vFilesetting = SearchFile("ibs/th/gbl/systemsetting.xml").
      if      vFileSetting ne ?
          and (   ikey + {utlcomp/keypriv.i} eq { utlcomp/keyset.i }
               or SystemKey eq {&SuperSysKey})    
      then do:
         
         xmldom-load(vFileSetting).
         xmldom-read-unique("settings","PumpTxtRead",output vText, output vFound).
         PumpTxtRead = logical(vText)no-error.
         xmldom-read-unique("settings","GetCashCurl",output vText, output vFound).
         GetCashCurl = logical(vText)no-error.
         xmldom-read-unique("settings","DeveloperMode",output vText, output vFound).
         DeveloperMode = logical(vText)no-error.
         xmldom-read-unique("settings","CrLogin",output CrLogin, output vFound).
         xmldom-read-unique("settings","CrPswd" ,output CrPswd , output vFound).
         xmldom-read-unique("settings","PumpFile" ,output PumpFile , output vFound).
         xmldom-read-unique("settings","AsiFile" ,output AsiFile , output vFound).
      

      end.
   end constructor.
  
    
    { utl/search.i class }
end class.