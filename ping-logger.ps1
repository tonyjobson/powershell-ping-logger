#setup a few file name variables
$hostname = $env:computername 

#let's get a time stamp we like
$YEARSTART = get-date -format yyyyMMdd;
$TIMESTART = get-date -format HHmmss


#let's ask them where to ping to start with
$destination = Read-Host -Prompt "What should we ping. Enter for 8.8.8.8 as a default"
if ($destination -eq '') {$destination = '8.8.8.8'}



#let's work out where to log this to:
$DefaulLogName = "PingLog-$hostname-TO-$destination-$YEARSTART-$TIMESTART.CSV"
$logname = read-host -Prompt "Where should we log this? Default $DefaulLogName"
if ($logname -eq ''){$LogName = $DefaulLogName}


#let's setup the csv file
add-content ./$logname "Year,Time,ResponseTime";


#pretend start time is successful ping to calculate seconds since sucsessful response in case we never get a response.
$LastSuccessful = get-date


while($true)
{

        $res = Test-Connection $destination -Count 1 -ErrorAction SilentlyContinue

        if ($res-eq $null) 
            {
                #let's work out how long since a last sucsessful ping.
                $TimeSpan = [DateTime](get-date) - [DateTime]$LastSuccessful

                $TotalSeconds = $timespan.TotalSeconds
                
                #let's give the user something to see for the failures.
                $TIMENOW = get-date -format HH:mm.ss
                Write-host "$TIMENOW : Last Ping Timed out. Logged to file. $TotalSeconds Since last sucsess"
    
                #log to a file the failure.
                $YEAR = get-date -format yyyy-MM-dd;
                $TIME = get-date -format HH:mm:ss
                add-content ./$logname "$YEAR,$TIME,4001";

                #incase the nic goes down we need a delay here too. means that our highest resolution of outage is 5 seconds.
                start-sleep -s 1
            }

        else
            {
                #if we get here then it means we got a response to the ping message inside of the default 4 second time out.
                
                #Update the time since sucsessful in case the next ping fails.
                $LastSuccessful = get-date
                
                $TIMENOW = get-date -format HH:mm:ss
                $pingtime = $res.ResponseTime
                Write-host "$TIMENOW : Ping Successful. Reponse Time = $pingtime"



                 #log time to a file.
                $YEAR = get-date -format yyyy-MM-dd;
                $TIME = get-date -format HH:mm:ss;
                 add-content ./$logname "$YEAR,$TIME,$pingtime";

                #pause for 1 second to prevent low latency loop being too quick.
                start-sleep -s 1

                #set $res to null in case the ping starts to fail or 
            }


}