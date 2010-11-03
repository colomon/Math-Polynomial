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

    method Str() returns Str
    {
        @.coefficients.kv.map({ "$^value x^$^key" }).reverse.join: ' + ';
    }

    method perl() returns Str
    {
        self.WHAT.perl ~ ".new(" ~ @.coefficients».perl.join(', ') ~ ")";
    }

    method evaluate($x)
    {
        @.coefficients.reverse.reduce: { $^a * $x + $^b };
    }

    multi sub infix:<+>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT)
    {
        my $max =   $a.coefficients.elems
                max $b.coefficients.elems;

        $a.new: (    $a.coefficients, 0 xx *
                  Z+ $b.coefficients, 0 xx * )[^$max];
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
        my @coef;
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
