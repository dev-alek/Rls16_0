
/*------------------------------------------------------------------------
    File        : route_date_error
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Daru
    Created     : Sun Jan 08 18:45:37 MSK 2023
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

interface ibs.th.rul.route_date_error:  
  method public void setError (iText as char).
end interface.