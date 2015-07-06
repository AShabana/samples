#!/usr/bin/perl
# This script search for failed (http) executoin sample and resend it again  

my $sample= '140305135644 D27FC700 1     exec_curl                           (   23) curl "http://10.245.211.80:8007/cgi-bin/sendsms?username=nemra1&password=koko88&smsc=GNCheck_stc&from=IDC&to=96653690034&text=%06%39%06%44%06%45%06%27%06%4B%00%20%06%28%06%23%06%46%00%20%06%27%06%44%06%45%06%42%06%27%06%39%06%2F%00%20%06%45%06%2D%06%2F%06%48%06%2F%06%29%00%0A%00%0A%06%45%06%39%00%20%06%2A%06%2D%06%4A%06%27%06%2A%00%20%06%45%06%31%06%43%06%32%00%20%06%27%06%44%06%2A%06%46%06%45%06%4A%06%29%00%20%06%27%06%44%06%35%06%46%06%27%06%39%06%4A%06%29&account=Sahara3&limit=6&udh=%05%00%03%04%05%05&coding=2&dlr-mask=7&dlr-url=http%3a%2f%2f10.245.211.80%3a3901%2fdlr%3finterface%3dsmpp%26port%3d2012%26aid%3d313%26kport%3d3901%26statusid%3d%25d%26msgid%3d9f887c91-8f93-4c7e-bec5-97192e485282%26smppid%3d1505134%26to%3d%25P%26from%3d%25p%26timestamp%3d%25t%26smsc%3d%25i%26smscid%3d%25I%26statusmsg%3d%25A%26smscprovidedID%3d%25F%26mpslinkid%3d328%26MNum%3d1%26INT%3d2%26account%3dSahara3%26prefix%3d96653%26altprefix%3d96602%26clienturl%3d"';



my $pat = '^(.*?) (curl.*?&to=(.*?)&text.*)';
open FD , "<" , $ARGV[0]  or die $! ;
$i=0;
while (<FD>)
{

                $line = $_ ;
                if ( $line =~ m/$pat/ )
                {
                                $url = $2 ;
                                $no = $3;


                                #search for no. at /var/log/kannel/home/support/resend.log
                                $cmd = "grep -c $no /var/log/kannel/home/support/resend.log ";
                                $res=`$cmd`;
                                if ( $res > 0 ) {
                                        $i++ ;
                                        $result = `$url`;
                                        print " $result ($no) \n"
                                        ##open(URL, "$url  |")  || print "Failed -> $url" ;
                                        ##while ( <URL> ) { print URL };
                                }
                }
}
print $i;
