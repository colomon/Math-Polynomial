use v6;

class Math::Polynomial {
    has @.coefficients;

    multi method new (*@coefficients) {
        self.new(@coefficients);
    }

    multi method new (@x is copy) {
        while @x > 1 && @x[*-1].abs < 1e-13 {
            @x.pop;
        }

        @x.push(0) if @x.elems == 0;

        self.bless(*, coefficients => @x);
    }

    method Str() returns Str {
        @.coefficients.kv.map({ "$^value x^$^key" }).reverse.join(' + ');
    }

    method perl() returns Str {
        "Math::Polynomial.new(" ~ @.coefficients».perl.join(', ') ~ ")";
    }

    method Bool() { self.is-nonzero }

    method evaluate($x) {
        @.coefficients.reverse.reduce({ $^a * $x + $^b });
    }

    method degree() { @.coefficients - 1 }

    method is-zero() { @.coefficients == 1 && @.coefficients[0] == 0 }
    method is-nonzero() { !self.is-zero; }
    method is-monic() { self.coefficients > 0 && self.coefficients[*-1] == 1 }

    method monize() {
        return self if self.is-zero || self.is-monic;
        return self / self.coefficients[*-1];
    }

    multi sub infix:<==>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        my $max =   $a.coefficients.elems
                max $b.coefficients.elems;

        all((    $a.coefficients, 0 xx *
             Z== $b.coefficients, 0 xx * )[^$max]);
    }
    multi sub infix:<!=>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        !($a == $b);
    }

    multi sub infix:<+>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        my $max =   $a.coefficients.elems
                max $b.coefficients.elems;

        $a.new: (    $a.coefficients, 0 xx *
                  Z+ $b.coefficients, 0 xx * )[^$max];
    }

    multi sub infix:<+>(Math::Polynomial $a, $b) is export(:DEFAULT) {
        my @ac = $a.coefficients;
        @ac[0] += $b;
        return $a.new(@ac);
    }

    multi sub infix:<+>($b, Math::Polynomial $a) is export(:DEFAULT) {
        $a + $b;
    }

    multi sub prefix:<->(Math::Polynomial $a) is export(:DEFAULT) {
        $a.new($a.coefficients.map({-$_}));
    }

    multi sub infix:<->(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        -$b + $a;
    }

    multi sub infix:<->(Math::Polynomial $a, $b) is export(:DEFAULT) {
        my @ac = $a.coefficients;
        @ac[0] -= $b;
        return $a.new(@ac);
    }

    multi sub infix:<->($b, Math::Polynomial $a) is export(:DEFAULT) {
        -$a + $b;
    }

    multi sub infix:<*>(Math::Polynomial $a, Math::Polynomial $b) is export(:DEFAULT) {
        my @coef;
        for     $a.coefficients.kv -> $ak, $av {
            for $b.coefficients.kv -> $bk, $bv {
                @coef[ $ak + $bk ] += $av * $bv;
            }
        }

        return $a.new(@coef);
    }

    multi sub infix:<*>(Math::Polynomial $a, $b) is export(:DEFAULT) {
        $a.new($a.coefficients »*» $b);
    }

    multi sub infix:<*>($b, Math::Polynomial $a) is export(:DEFAULT) {
        $a.new($a.coefficients »*» $b);
    }

    multi sub infix:</>(Math::Polynomial $a, $b) is export(:DEFAULT) {
        $a.new($a.coefficients »/» $b);
    }

    multi sub infix:<**>(Math::Polynomial $a, Int $b where $b >= 0) is export(:DEFAULT) {
        $b == 0 ?? Math::Polynomial.new(1)
                !! ($a xx $b).reduce(* * *);
    }

    # sub _divmod($this, $that) {
    #     my @den  = $that.coefficients;
    #     @den or croak 'division by zero polynomial';
    #     my $hd   = pop @den;
    #     if ($that->is_monic) {
    #         undef $hd;
    #     }
    #     my @rem  = $this->coeff;
    #     my @quot = ();
    #     my $i    = $#rem - @den;
    #     while (0 <= $i) {
    #         my $q = pop(@rem);
    #         if (defined $hd) {
    #             $q /= $hd;
    #         }
    #         $quot[$i] = $q;
    #         my $j = $i--;
    #         foreach my $d (@den) {
    #             $rem[$j++] -= $q * $d;
    #         }
    #     }
    #     return (\@quot, \@rem);
    # }

}
