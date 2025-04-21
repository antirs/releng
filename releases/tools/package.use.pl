#! /usr/bin/perl -wnl -s
#
# generate package.use{.force,.mask} from emerge output.
#
# Usage:
#    ./package.use.pl <FILE> > package.use
#    ./package.use.pl -mode=1 <FILE> > package.use.force
#    ./package.use.pl -mode=2 <FILE> > package.use.mask

BEGIN {
    our $mode = '0' if !defined $mode;
    our $slots = '1' if !defined $slots;
    open(OUTPUT, '|sort|uniq|grep -v ^$');
}

my $force = '1';
my $mask = '2';

{
    $^W = 0;
    s/\[[^]]+\] //g;                      # emerge
    s/^([^ :]+)-[[:digit:]]:/$1:/;        # package build id
    s/^([^ :]+)-[[:digit:]]+(\.[[:digit:]]+)*[a-z]?(_(alpha|beta|pre|rc|p)[[:digit:]]*)*(-r[[:digit:]]+)?:/$1:/; # version
    s/(:[^:\/]+)\/[^:]+::/::/;            # subslot
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

print OUTPUT;
