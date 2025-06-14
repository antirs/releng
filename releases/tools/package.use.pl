#! /usr/bin/perl -wnl -s
#
# generate package.use{.force,.mask} from emerge output.
#
# Usage:
#    ./package.use.pl <FILE> > package.use
#    ./package.use.pl -mode=1 <FILE> > package.use.force
#    ./package.use.pl -mode=2 <FILE> > package.use.mask

BEGIN {
    $ENV{LC_COLLATE} = 'C';
    our $mode = '0' if !defined $mode;
    our $slots = '1' if !defined $slots;
    our $filter = '' if !defined $filter;
    open(OUTPUT, '|sort|uniq|grep -v ^$');
}

my $force = '1';
my $mask = '2';
my @filters = split(",", $filter);

{
    $^W = 0;
    s/^\[[^]]+\] //g;                     # emerge
    s/\[[^]]+\]//g;                       # update
    s/^([^ :]+)-[[:digit:]]:/$1:/;        # package build id
    s/^([^ :]+)-[[:digit:]]+(\.[[:digit:]]+)*[a-z]?(_(alpha|beta|pre|rc|p)[[:digit:]]*)*(-r[[:digit:]]+)?:/$1:/; # version
    s/(:[^:\/]+)\/[^:]+::/::/;            # subslot
    s/ to [^ ]+/ /;                       # ROOT
    s/([^ ]+) +(USE="[^"]*")? .*/$1  $2/; # use expands (TODO: rework)
    s/USE="([^"]+)"/$1/;                  # uses
    s/::[^ ]+//;                          # repository
    s/\(([^)]+)\)/$1/g;                   # parenthesis
    s/[*%]+//g;                           # updates
    s/.*is.*blocking.*//;                 # blocks
}

if ($slots eq '0') {
    s/:.+?(\s+)/$1/;  # slot (TODO: rework)
}

if ($mode eq $force) {
    s/ -([^ ]+)//g;
} elsif ($mode eq $mask) {
    s/( +)([^- ]+[^ ]+)/$1___$2___/g;
    # s/ +[^- ]+[^ ]+//g;
    s/ -([^ ]+)/ $1/g;
    s/___([^ ]+)___/-$1/g;
}

s/\s+$//;  # spaces

# sort uses
my @arr = split /  /;
if (defined $arr[1]) {
    my @uses = grep {
        my $use = $_;
        my $count = grep {
            $_ eq $use || "-$_" eq $use;
        } @filters;
        $count == 0; } sort { $a =~ /^-/ ?
                         $b =~ /^-/ ?
                         $a cmp $b :
                         1:
                           $b =~ /^-/ ?
                           -1:
                           $a cmp $b
                       } split / /, $arr[1];
    $_ = $arr[0].'  '."@uses";
}

print OUTPUT;
