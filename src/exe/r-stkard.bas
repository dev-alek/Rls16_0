Sub Main_Macros(vParam As String, vDelimiter As String)
  Dim iNumEntries As Integer , iNumEntry As Integer , iEntry As String , iEntryCheck as Integer
  Dim iFirstRow As Integer, iRow As Integer , iEndRow As Integer, sRowNum As String
  Dim iStartGroup As Integer , iEndGroup As Integer
  Dim sStartGroup As String , sEndGroup As String



  Rows("1:5").Select
  Selection.Delete Shift:=xlUp

  iEndRow = ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell).Row



End Sub
