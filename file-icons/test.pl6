#!/usr/bin/env raku

class TemperatureConverter {
    method celsius-to-fahrenheit(Numeric $c --> Numeric) {
        $c * 9/5 + 32
    }

    method fahrenheit-to-celsius(Numeric $f --> Numeric) {
        ($f - 32) * 5/9
    }
}

sub MAIN(Numeric $temp, Str :$from = 'C') {
    my $converter = TemperatureConverter.new;

    given $from.uc {
        when 'C' {
            my $f = $converter.celsius-to-fahrenheit($temp);
            say "{$temp}°C = {$f.round(0.01)}°F";
        }
        when 'F' {
            my $c = $converter.fahrenheit-to-celsius($temp);
            say "{$temp}°F = {$c.round(0.01)}°C";
        }
        default { die "Unknown unit: $from. Use C or F." }
    }
}
