function dummy (){


function Get-ISO8601Week (){
# Adapted from https://stackoverflow.com/a/43736741/444172
# Example: Get-Date | Get-ISO8601Week
  [CmdletBinding()]
  param(
    [Parameter(
      ValueFromPipeline                =  $true,
      ValueFromPipelinebyPropertyName  =  $true
    )]                                           [datetime]  $DateTime
  )
  process {
    foreach ($_DateTime in $DateTime) {
      $_ResultObject   =  [pscustomobject]  @{
        Year           =  $null
        WeekNumber     =  $null
        WeekString     =  $null
        DateString     =  $_DateTime.ToString('yyyy-MM-dd   dddd')
      }
      $_DayOfWeek      =  $_DateTime.DayOfWeek.value__

      # In the underlying object, Sunday is always 0 (Monday = 1, ..., Saturday = 6) irrespective of the FirstDayOfWeek settings (Sunday/Monday)
      # Since ISO 8601 week date (https://en.wikipedia.org/wiki/ISO_week_date) is Monday-based, flipping Sunday to 7 and switching to one-based numbering.
      if ($_DayOfWeek  -eq  0) {
        $_DayOfWeek =    7
      }

      # Find the Thursday from this week:
      #     E.g.: If original date is a Sunday, January 1st     , will find     Thursday, December 29th     from the previous year.
      #     E.g.: If original date is a Monday, December 31st   , will find     Thursday, January 3rd       from the next year.
      $_DateTime                 =  $_DateTime.AddDays((4  -  $_DayOfWeek))

      # The above Thursday it's the Nth Thursday from it's own year, wich is also the ISO 8601 Week Number
      $_ResultObject.WeekNumber  =  [math]::Ceiling($_DateTime.DayOfYear    /   7)
      $_ResultObject.Year        =  $_DateTime.Year

      # The format requires the ISO week-numbering year and numbers are zero-left-padded (https://en.wikipedia.org/wiki/ISO_8601#General_principles)
      # It's also easier to debug this way :)
      $_ResultObject.WeekString  =  "$($_DateTime.Year)-W$("$($_ResultObject.WeekNumber)".PadLeft(2,  '0'))"
      Write-Output                  $_ResultObject
    }
  }
}




} # function dummy