unit module Config::Reader;

class Config {
    has %.data;

    method load(Str $path --> Config) {
        my %result;
        for $path.IO.lines -> $line {
            next if $line ~~ /^ \s* '#' | ^ \s* $/;
            if $line ~~ /^ (\w+) \s* '=' \s* (.*) $/ {
                %result{~$0} = ~$1;
            }
        }
        self.bless(data => %result);
    }

    method get(Str $key, Str $default = '' --> Str) {
        %.data{$key} // $default;
    }

    method keys(--> Seq) {
        %.data.keys.sort;
    }
}
