#region Function
function Add-Numbers {
  Param(
    [int[]]$Numbers
  )
  $Total = [int]0
  foreach ($Number in $Numbers) {
    $Total += $Number
  }
  return $Total
}
#endregion

$PizzasEaten = [int]0

$PizzasEaten = Add-Numbers(2,5,10)

$Message = "Pizzas eaten so far $PizzasEaten"

Write-Output $Message

$PizzasEaten = Add-Numbers($PizzasEaten,3)

$Message = "Finale pizzas totale = $PizzasEaten"
Write-Output $Message
