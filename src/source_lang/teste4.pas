program kek;

var
  b: bool;
var
  i, x: integer;

var
  vaipls: array[1..10] of integer;
begin
  while x <= 5
  do
    if x = 3
    then x := 3
    else x := x;
    i := 0;
    x := x + 1;
    result := i + x;
    write(result)
end.
