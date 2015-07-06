#!/usr/bin/perl
# script input format log-format = "%l [SMSC:%i] [ACT:%A] [FID:%F] [from:%p] [to:%P] [msg:%L:%b] [udh:%U:%u]"
=sample of the script input 
2015-06-26 00:07:27 Log begins
2015-07-06 13:58:29 Sent SMS [SMSC:XXX3] [ACT:alerts] [FID:10b8637f] [from:RiyadCapitl] [to:966555615895] [msg:116:0036003000320030000D000A0642062F0020062A06450020062A06460641064A06300647002006280646062C0627062D00200628062A06270631064A062E003A00200032003000310035002D00300037002D00300036002000310034003A00350037003A00350033000D000A0639062F062F0020] [udh:6:050003F10402]
2015-07-06 13:58:29 Sent SMS [SMSC:XXX_adv] [ACT:Bulk77002] [FID:aa56479] [from:Najcci] [to:966564666121] [msg:110:.........)] [udh:0:]
2015-07-06 13:58:29 Receive DLR [SMSC:XXX3] [ACT:alerts] [FID:10b8637f] [from:RiyadCapitl] [to:966555615895] [msg:116:0036003000320030000D000A0642062F0020062A06450020062A06460641064A06300647002006280646062C0627062D00200628062A06270631064A062E003A00200032003000310035002D00300037002D00300036002000310034003A00350037003A00350033000D000A0639062F062F0020] [udh:6:050003F10402]
2015-07-06 13:58:29 Receive DLR [SMSC:XXX_adv] [ACT:Bulk77002] [FID:aa56479] [from:Najcci] [to:966564666121] [msg:110:id:0178611321 sub:001 dlvrd:001 submit date:1507061458 done date:1507061458 stat:DELIVRD err:000 text:.:.1.A.)] [udh:0:]
=cut
=Cmd to run
cat sample.log | perl parser.pl [web]
=cut
=Sample of command output (report generated)
Summary :-
========
	Total SMS : 2 , Total DLR : 2 { Success : 1 , Failed : 1 }
SMSC ID : aa56479 :
-----------------
	SMS : @( 2015-07-06 13:58:29 ) Account : (Bulk77002) , From : (Najcci) , To : (966564666121) , MSG :(.........))
	DLR : @( 2015-07-06 13:58:29 ) -> (id:0178611321 sub:001 dlvrd:001 submit date:1507061458 done date:1507061458 stat:DELIVRD err:000 text:.:.1.A.))

SMSC ID : 10b8637f :
------------------
	SMS : @( 2015-07-06 13:58:29 ) Account : (alerts) , From : (RiyadCapitl) , To : (966555615895) , MSG :(0036003000320030000D000A0642062F0020062A06450020062A06460641064A06300647002006280646062C0627062D00200628062A06270631064A062E003A00200032003000310035002D00300037002D00300036002000310034003A00350037003A00350033000D000A0639062F062F0020)
	DLR : @( 2015-07-06 13:58:29 ) -> (0036003000320030000D000A0642062F0020062A06450020062A06460641064A06300647002006280646062C0627062D00200628062A06270631064A062E003A00200032003000310035002D00300037002D00300036002000310034003A00350037003A00350033000D000A0639062F062F0020)
=cut


#Main()
# #---------'1->date              $3->smsc         $4->ACT       $5->FID     $6->from       $7->to               $8->msg_txt
$Pat = '((.+? ){2}).*?\[SMSC\:(\w+?)\] .*?\[ACT\:(.*?)\] .*?\[FID\:(.*?)\] .*?\[from\:(.*?)\] \[to\:(.*?)\] .*?\[msg\:\d+\:(.*?)\].*' ;


my %FIDHT ;
my %COUNTER ;
$DEBUG=0;
$DEBUG = $ARGV[0] ;
my $_BOLD ;
my $EOL;
my $_blue;
my $_red = sub {;};
my $_green = sub {;} ;
my $TOTAL = 2;
my $FAILED = 1;
my $SUCCESS = 0;
$COUNTER{'DLR'}[$SUCCESS] = 0 ;
$COUNTER{'DLR'}[$FAILED] = 0 ;
$COUNTER{'DLR'}[$TOTAL] = 0 ;
$COUNTER{'SMS'} = 0 ;

if ( $ARGV[1] eq 'web'){
	$EOL = "</br>";
	$_BOLD = sub{
		return '<b>'. $_[0] . '</b>' ;
	};
	$_blue = sub{
		'<b><font color="blue">'. $_[0] . '</font></b>' ;
	};
	$_red = sub{
		'<b><font color="red">'. $_[0] . '</font></b>' ;
	};
	$_green = sub{
		'<b><font color="green">'. $_[0] . '</font></b>' ;
	};
}else{

	$EOL = "\n" ;
	$_BOLD = sub{
        	return "\e[1;;1m" . $_[0] . "\e[0m" ;
	};
	$_blue = sub{
		return "\e[44;37;1m" .$_[0] . "\e[0m" ;
	};
	$_red = sub{
		return "\e[31;1m" . $_[0] . "\e[0m" ;
	};
	$_green = sub {
		return "\e[32;1m" . $_[0] . "\e[0m";
	};
	
}

sub dlr_fmt 
{ 	$arg = $_[0] ;
	if ( $arg =~ m/stat:DELIVRD err:000/ ){
		$COUNTER{'DLR'}[$SUCCESS]++; 
		&$_green($arg) ;
	}
	else {   
		$COUNTER{'DLR'}[$FAILED]+=1;
		&$_red($arg) ; 
	}
}


while (<STDIN>)
{
        my $line = $_ ;
	if ( $DEBUG) { print "$line $EOL"; }
	if ( substr( $line, 20, 11 ) eq 'Receive DLR') { #/* Receive DLR*/
		$COUNTER{'DLR'}[$TOTAL]++ ;
		if ( $line =~ m/$Pat/ ) #/* Filter Messages table Entities */
                {	
                        $FIDHT{$5}[1] = "@( " . &$_BOLD($1) . ") -> (" . dlr_fmt($8) . ") ";
                }
        }elsif ( $line =~ m/$Pat/ ){
                        $FIDHT{$5}[0] = "@( " . &$_BOLD($1) . ") Account : (".&$_green($4) .") , From : (" . &$_green($6) .") , To : (" . &$_green($7) . ") , MSG :(". &$_BOLD($8) . ") ";
		
        		$COUNTER{'SMS'}++;
	}
                
}
print "Summary :-$EOL";
print "========$EOL";
print "\tTotal SMS : " .$COUNTER{'SMS'}." , Total DLR : ".$COUNTER{'DLR'}[$TOTAL].
" { Success : ".$COUNTER{'DLR'}[$SUCCESS]." , Failed : ".$COUNTER{'DLR'}[$FAILED]." }$EOL";
foreach my $fid ( keys  %FIDHT ){
        print "SMSC ID : $fid :$EOL----------". '-' x length($fid) ."$EOL\tSMS : " . $FIDHT{$fid}[0] . "$EOL\tDLR : " . $FIDHT{$fid}[1] ."$EOL $EOL";
}
print "Summary format 2:- $EOL";
print "================$EOL";
foreach my $fid ( keys %FIDHT ){
        print "Message Id :  $fid $EOL" ;
        print "Destination : $FIDHT{$fid}[3] $EOL" ;
        print "TimeStamp : $FIDHT{$fid}[4] $EOL" ;
        print "Sender : $FIDHT{$fid}[2] $EOL" ;
        if ( defined $FIDHT{$fid}[5] ){
            print "Status : " . dlr_status($FIDHT{$fid}[5]);
        }else{
            print "Status : -" ;
        }
        print "$EOL $EOL $EOL" ;
}
exit 0 ;
