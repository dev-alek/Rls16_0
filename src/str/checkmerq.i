
/*------------------------------------------------------------------------
    File        : temp_merq.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Fri Nov 27 17:55:35 MSK 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */
 
/* ***************************  Main Block  *************************** */


PROCEDURE checkguid :
  define INPUT-output parameter guid_ as CHARACTER NO-UNDO .
  define OUTPUT parameter Msg as CHARACTER  NO-UNDO .

  def var ii      as int       no-undo.
  def var err     as logical   no-undo.
  def var str     as character no-undo.
  def var numentr as integer   no-undo.
    
  numentr = num-entries (guid_, "-") no-error.
  if numentr = 8
    then 
  do:
    do ii = 1 to numentr:
      if length (trim (entry (ii, guid_, "-"))) <> 4
        then err = true.
      str = str + trim (entry (ii, guid_, "-")).
      
      if ii = 2 or ii = 3 or ii = 4 or ii = 5
        then 
      do:
        str = str + "-".
      end.
    end.
    guid_ = str.
  end.
    
  numentr = num-entries (guid_, "-") no-error.
    
  do ii = 1 to numentr:
      
    case ii:
      when 1 then 
        do:
          if length (trim (entry (ii, guid_, "-"))) <> 8
            then err = true.
        end.
      when 2 or 
      when 3 or 
      when 4 then 
        do:
          if length (entry (ii, guid_, "-")) <> 4
            then err = true.
        end.
      when 5 then 
        do:
          if length (entry (ii, guid_, "-")) <> 12
            then err = true.
        end.
    end case.
      

  end.
  if ii <> 6 
    then err = true. 
  if err then Msg = "Неверный формат GUID".
    
END PROCEDURE.

