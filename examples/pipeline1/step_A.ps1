﻿[CmdletBinding(SupportsShouldProcess)]
$params = @{
	Path = "./data/voters.txt"
};
$globals = @{
	Foo = "Bar"
};

../components/ReadFile.ps1 @params
