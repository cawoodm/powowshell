const { spawn } = require("child_process");
const precise = require("precise");

// This terminates immediately
//const ps1 = spawn("Get-Date", [], {shell:"pwsh"});

const ps1 = spawn("pwsh.exe", [], {});
//console.log("PID", ps1.pid, "started");

let buffer = "";
let ShellState = 0;
ps1.stdout.on('data', (data)=>{

  // Convert buffer to raw string
  let raw = data.toString();
  
  // Normalize newlines
  raw = raw.replace(/\r\n?/g, '\n');
  
  // Parse by newlines
  let lines = raw.split('\n');

  // If final line is not empty, we don't have the full line and we need to buffer
  if (lines[lines.length-1]!=="") {
    buffer += lines.pop();
  } else if (buffer) {
    // Add any previous buffer we may have
    lines[0] = buffer + lines[0];
    buffer = "";
  }

  // Remove trailing newline (\n) at the end of each line
  if (lines[lines.length-1]==="")
    lines.pop();
  
  // Output lines
  for (let l=0; l<lines.length; l++) {
    let line = lines[l];

    // Wait for shell to be initialized
    //  so we skip copyright header etc.
    if (ShellState===0) {
      if (line.match(/^-------$/)) {
        ShellState = 1
      }
      continue
    }

    // Skip PS prompt (echo of each command we type)
    if (line.match(/^PS .*/)) continue;

    if (ShellState > 0)
      console.log(line);
  }

});

ps1.stderr.on('data', (data)=>{
  console.log("STDERR:"+data);
});

ps1.on('close', (code, signal) => {
  console.log(`child process terminated due to receipt of signal ${signal}`);
});

ps1.stdin.write("Write-Output \"-------\"\n");
setInterval(()=>{
  //ps1.stdin.write("Get-Content names.txt | Select -First 2\n");
  ps1.stdin.write("Import-Csv names.txt -Delimiter \" \" -Header first,last | Select -First 2 | ConvertTo-Json\n");
}, 3000);