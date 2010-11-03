use v6;

class Math::Polynomial
{
    has @.coefficients;

    multi method new (*@x)
    {
        self.new: @x.item;
    }

    multi method new (@x is copy)
    {
        while @x.elems > 1 && @x[*-1].abs < 1e-13
        {
            # say @x.perl;
            # say @x[*-1];
            @x.pop;
        }

        @x.push: 0 if @x.elems == 0;

        self.bless: *, coefficients => @x;
    }

    multi method Str() returns Str
    {
        @.coefficients.kv.map({ "$^value x^$^key" }).reverse.join: ' + ';
    }

    multi method perl() returns Str
    {
        self.WHAT.perl ~ ".new(" ~ @.coefficients».perl.join(', ') ~ ")";
    }

    multi method evaluate($x)
    {
        # would be more elegant with Z+, once that works
        my $result = @.coefficients[0] * 0;
        for @.coefficients Z (1, $x, $x * $x ... *) -> $a, $z {
            $result = $result + $a * $z;
        }
        $result;
    }

    multi sub infix:<+>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT)
    {
        my @poly = gather for ^(+$a.coefficients max +$b.coefficients) -> $i {
            if $i < +$a.coefficients && $i < +$b.coefficients {
                take $a.coefficients[$i] + $b.coefficients[$i];
            } elsif $i < +$a.coefficients {
                take $a.coefficients[$i];
            } else {
                take $b.coefficients[$i];
            }
        }

        $a.new: @poly;
    }

    multi sub infix:<+>(Math::Polynomial $a, $b) is export(:DEFAULT)
    {
        my @ac = $a.coefficients;
        @ac[0] += $b;
        return $a.new: @ac;
    }

    multi sub infix:<+>($b, Math::Polynomial $a) is export(:DEFAULT)
    {
        $a + $b;
    }

    multi sub prefix:<->(Math::Polynomial $a) is export(:DEFAULT)
    {
        $a.new: $a.coefficients.map({-$_});
    }

    multi sub infix:<->(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT)
    {
        -$b + $a;
    }

    multi sub infix:<->(Math::Polynomial $a, $b) is export(:DEFAULT)
    {
        my @ac = $a.coefficients;
        @ac[0] -= $b;
        return $a.new: @ac;
    }

    multi sub infix:<->($b, Math::Polynomial $a) is export(:DEFAULT)
    {
        -$a + $b;
    }

    multi sub infix:<*>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT)
    {
        my @coef = 0.0 xx ($a.coefficients.elems + $b.coefficients.elems - 1);
        for     $a.coefficients.kv -> $ak, $av {
            for $b.coefficients.kv -> $bk, $bv {
                @coef[ $ak + $bk ] += $av * $bv;
            }
        }

        return $a.new: @coef;
    }

    multi sub infix:<*>(Math::Polynomial $a, $b) is export(:DEFAULT)
    {
        $a.new: $a.coefficients >>*>> $b;
    }

    multi sub infix:<*>($b, Math::Polynomial $a) is export(:DEFAULT)
    {
        $a.new: $a.coefficients >>*>> $b;
    }

    multi sub infix:</>(Math::Polynomial $a, $b) is export(:DEFAULT)
    {
        $a.new: $a.coefficients >>/>> $b;
    }
}
