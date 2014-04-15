package Method::Generate::BuildAll;

use strictures 1;
use base qw(Moo::Object);
use Sub::Quote qw(quote_sub quotify);
use Moo::_Utils;

sub generate_method {
  my ($self, $into) = @_;
  quote_sub "${into}::BUILDALL", join '',
    $self->_handle_subbuild($into),
    qq{    my \$self = shift;\n},
    $self->buildall_body_for($into, '$self', '@_'),
    qq{    return \$self\n};
}

sub _handle_subbuild {
  my ($self, $into) = @_;
  '    if (ref($_[0]) ne '.quotify($into).') {'."\n".
  '      return shift->Moo::Object::BUILDALL(@_)'.";\n".
  '    }'."\n";
}

sub buildall_body_for {
  my ($self, $into, $me, $args) = @_;
  my @builds;
  require Moo;
  for my $class (@{Moo::_Utils::_get_linear_isa($into)}) {
    if ($class eq 'Moo::Object') {
      last;
    }
    my $new = *{_getglob("${class}::new")}{CODE};
    if (!defined $new) {
    }
    elsif (my $defer_target = (Sub::Defer::defer_info($new)||[])->[0]) {
      my ($pkg) = ($defer_target =~ /^(.*)::[^:]+$/);
      if (!$Moo::MAKERS{$pkg}) {
        last;
      }
    }
    else {
      last;
    }
    my $build = "${class}::BUILD";
    if (*{_getglob($build)}{CODE}) {
      unshift @builds, $build;
    }
  }
  join '', map qq{    ${me}->${_}(${args});\n}, @builds;
}

1;
