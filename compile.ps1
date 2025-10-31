iverilog -o adder.vvp adder.v (Get-ChildItem -Recurse -Filter *.v | ForEach-Object { $_.FullName })
iverilog -o adder_tb.vvp adder_tb.v (Get-ChildItem -Recurse -Filter *.v | ForEach-Object { $_.FullName })
iverilog -o adder_tb.vcd adder_tb.v (Get-ChildItem -Recurse -Filter *.v | ForEach-Object { $_.FullName })